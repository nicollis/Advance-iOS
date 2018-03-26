from app import app
from flask import jsonify, render_template
import random
# department names

random.seed('128')  # need a shiny monkeydog


adjectives = [
    "Awesome",
    "Boogie Boogie",
    "Curly",
    "Excellent",
    "Matte",
    "Pearl",
    "Red",
    "Shiny",
    "Spiffy",
    "Wired" ]

nouns = [
    "Ambulance",
    "Badger",
    "Bike",
    "Book",
    "Calendar",
    "Cassette",
    "Cat",
    "Gorilla Suit",
    "Hedgehog",
    "Monkeydog",
    "Mouse",
    "Oboe",
    "Pilates Rack",
    "Sippy Cup",
    "Telephone",
    "Yoga Pants" ]

materials = [
    "100% Cotton",
    "40-pound Paper",
    "50/50 Polycotton",
    "Cat Fur",
    "Ceramic",
    "Dihydrogenmonoxide"
    "Fine Corinthian Leather",
    "Slate Tile",
    "Spun Polyester" ]

descriptions = [
    "Featuring a stainless steel case encrusted with diamonds.",
    "Sure to be a hit at your next office party!",
    "The strap is a black stingray band with a ladybug clasp.",
    "Featuring stumpwork raspberries in oversized miniature proportions.",
    "Smoothest double-clicking action this side of the Mississippi.",
    "Patented 10cc/min removable drinking straw.",
    "Includes Break Resistant Plasti-Pearl Buttons.",
    "Plutonium-powered reactor for longevity and safety.",
    "Red Lectroid endorsed!",
    "Because cows aren't big enough.",
    "Stitched on 100 count Aida cloth.",
    "Enter your PIN number into the ATM machine.",
    "Thank you for supporting your local Programmer." ]

specifications = [
    "Guaranteed non-flammable",
    "Requires occasional feeding",
    "Oscillation Overthruster",
    "Optional Sonic Screwdriver attachment",
    "Produced from organically grown 260Q balloons",
    "Transdermal HDMI output",
    "Batteries not included",
    "Batteries included",
    "Tenor clef transposition required",
    "Indoor cycling powered",
    "Liked on social media",
    "Autotweets meals",
    "Gothic poetry in limerick form",
    "Usable to ISO 6400",
    "Magnetic clutch technology",
    "Immanentizes the Eschaton",
    "Sharp up to f/64",
    "Backstitches not included",
    "Extra large tatting shuttle included",
    "Heart rate sensors are not supported",
    "Includes BlueTooth water bottle",
    "Not available in Arkansas" ]

alphabet = [
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
    'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z' ]

def create_random_product():
    name = "%s %s" % (random.choice(adjectives), random.choice(nouns))
    productNumber = "%s%s%s%d%d%d%d" % (random.choice(alphabet), random.choice(alphabet),
                                        random.choice(alphabet),
                                        random.randint(0, 9), random.randint(0, 9),
                                        random.randint(0, 9), random.randint(0, 9))
    price = random.randint(40, 9999)
    material = random.choice(materials)

    specs = random.sample(specifications, random.randint(1, 5))
    blurbs = random.sample(descriptions, random.randint(1, 4))

    goodies = {
        'name' : name,
        'number' : productNumber,
        'id' : productNumber,
        'price' : price,
        'material' : material,
        'specs' : specs,
        'blurbs' : blurbs,
        }
    return goodies

def create_categories(department):
    cats = { 'Consumer Products' : [ 'Discounts', 'Volumetrics' ],
             'Manufacturing' : [ 'Control Systems', 'Assembly Lines', 'Ferrets', 'High Voltage' ],
             'Retroencabulators' : [ 'Flange-arms' ],
             'Industrial Services' : [ 'Cute', 'Cuddly', 'Furry' ] }
    categories = cats[department['name']]
    return categories


def create_department(name, department_id):
    department = { 'name' : name, 'id' : department_id }
    
    categories = create_categories(department)
    department['categories'] = categories
    stuff = []
    
    for category in categories:
        products = []
        for i in range(random.randint(1, 10)):
            product = create_random_product()
            products.append(product)

        product_collection = { 'category' : category, 'products' : products }

        stuff.append(product_collection)

    department['departments'] = stuff
    return department


def create_catalog():
    catalog = { }
    for department in [ ('Consumer Products', 'c101'),
                        ('Manufacturing', 'c102'),
                        ('Retroencabulators', 'c103'),
                        ('Industrial Services', 'c104') ]:
        name = department[0]
        id = department[1]
        department = create_department(name, id)
        catalog[id] = department
    return catalog
