from app import app
from flask import jsonify, render_template
from catalog import create_catalog
import auth

catalogs = create_catalog()


def template_catalogs():
    template_catalogs = []
    for key in catalogs.keys():
        id = catalogs[key]['id']
        name = catalogs[key]['name']
        template_catalogs.append({ 'id' : id, 'name' : name })
    return template_catalogs


def catalog_products(catalogid):
    departments = catalogs[catalogid]['departments']
    products = []
    for department in departments:
        category = department['category']
        all_products = department['products']
        for product in all_products:
            single_product = { 'name' : product['name'], 'id' : product['number'],
                               'price' : product['price'] }
            products.append(single_product)
    return products


def product_for_catalog_id(catalogid, productid):
    departments = catalogs[catalogid]['departments']
    found_product = None
    for department in departments:
        all_products = department['products']
        for product in all_products:
            if product['number'] == productid:
                found_product = product
                break

    return found_product


@app.route('/')
@app.route('/index')
def index():
    template_cats = template_catalogs()
    return render_template('index.html', title='Catalog', catalogs=template_cats)

@app.route('/api/catalogs')
@auth.maybe_requires_auth
def serve_api_catalogs():
    template_cats = template_catalogs()
    goodies = { 'response' : template_cats }
    return jsonify(goodies)
    


@app.route('/api/catalog-entire')
@auth.maybe_requires_auth
def serve_api_catalog_entire():
    goodies = { 'response' : catalogs }
    return jsonify(goodies)


@app.route('/catalog/<catalogid>')
def serve_catalog(catalogid):
    name = catalogs[catalogid]['name']

    products = catalog_products(catalogid)
    return render_template('catalog.html', title=name, catalogid=catalogid,
                           catalogname=name, products=products)


@app.route('/api/catalog/<catalogid>')
@auth.maybe_requires_auth
def serve_api_catalog(catalogid):
    name = catalogs[catalogid]['name']

    products = catalog_products(catalogid)
    goodies = { 'response' : products }

    return jsonify(goodies)


@app.route('/catalog/<catalogid>/product/<productid>')
def serve_catalog_product(catalogid, productid):
    product = product_for_catalog_id(catalogid, productid)
    productname = product['name']
    return render_template('product.html', title=productname, productid=productid,
                           catalogid=catalogid, product=product)

@app.route('/api/catalog/<catalogid>/product/<productid>')
@auth.maybe_requires_auth
def serve_api_catalog_product(catalogid, productid):
    product = product_for_catalog_id(catalogid, productid)
    goodies = { 'response' : product }
    return jsonify(goodies)

