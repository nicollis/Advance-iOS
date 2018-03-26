from functools import wraps
from flask import request, Response
import prefs


def check_auth(username, password):
    print "check auth"
    uname = prefs.username()
    pw = prefs.password()
    print (uname == None and pw == None) or (username == uname and password == pw)
    return (uname == None and pw == None) or (username == uname and password == pw)


def authenticate():
    return Response(
        'Could not verify your access level for this URL. '
        'Please log in with proper credentials', 401,
        { 'WWW-Authenticate' : 'Basic realm="Login Required"' })

# makes a @maybe_requires_auth decorator you can add to flask requests to conditionally
# require authorization.

def maybe_requires_auth(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if prefs.should_auth():
            auth = request.authorization
            if not auth or not check_auth(auth.username, auth.password):
                return authenticate()
        return f(*args, **kwargs)
    return decorated
