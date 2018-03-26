#!/usr/bin/python

import sys, getopt, os

defaults = {
    'username' : os.getlogin(),
    'password' : None,
    'SSL'      : False
}


# --------------------------------------------------

def username():
    return defaults['username']

def password():
    return defaults['password']

def should_auth():
    pw = password()
    return pw != None

def should_ssl():
    return defaults['SSL']


# --------------------------------------------------
# Look at the command-line for prefence tweaks

def usage():
    print 'run.py [--username=uname] [--password=pw] [--ssl]'

try:
    opts, args = getopt.getopt(sys.argv[1:], "hsu:p:", ["help", "ssl", "username=", "password="])
except getopt.GetoptError:
    usage()
    sys.exit(2)
    
for opt, arg in opts:
    if opt in ('-h', '--help'):
        usage()
        sys.exit()
    elif opt in ('-u', '--username'):
        defaults['username'] = arg
    elif opt in ('-p', '--password'):
        defaults['password'] = arg
    elif opt in ('-s', '--ssl'):
        defaults['SSL'] = True

