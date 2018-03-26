#!/usr/bin/python

import sys
sys.path.append('./lib/python/site-packages/')

from app import app
from app import prefs

if prefs.should_auth():
    print "running with auth for API - %s / %s" % (prefs.username(), prefs.password())

ssl_context = None

if prefs.should_ssl():
    from OpenSSL import SSL
    ssl_context = SSL.Context(SSL.SSLv23_METHOD)
    ssl_context.use_privatekey_file('ssl.key')
    ssl_context.use_certificate_file('ssl.cert')
    print "using https:  for https://localhost:5000"

# If you're on a newer Python that has ssl/SSLContext, this is easier and more secure
# import ssl
# context = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
# context.load_cert_chain('ssl.cert', 'ssl.key')

app.run(debug=True, ssl_context=ssl_context)
