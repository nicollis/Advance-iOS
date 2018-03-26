The First Fake Web Service
==========================

This is a [flask-based](http://flask.pocoo.org) web service, which is very easy
to get running and to do basic dynamic web content.


Running
-------
run `run.py`:

```
% ./run.py
 * Running on http://127.0.0.1:5000/
 * Restarting with reloader
127.0.0.1 - - [10/Oct/2014 11:07:27] "GET / HTTP/1.1" 200 -
```

and then visit [http://localhost:5000](http://localhost:5000)


Some flags you can use:

  * --help

Print out the usage
  * --username=snork
  * --password=b4dg3rZ

Use basic HTTP Auth with username "snork" and password "b4dg3rz"

  * --ssl

Use HTTPS for transport.  You'll need to make a key and certificate:



```
openssl genrsa 1024 > ssl.key
openssl req -new -x509 -nodes -sha1 -days 365 -key ssl.key > ssl.cert
```

If you'll be using SSL pinning, you'll want the binary form of the certificate:

```
openssl x509 -outform der -in ssl.cert -out ssl.der
```
