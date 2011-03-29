#!/usr/bin/env python

import sys
import urllib
import urllib2

user_agent = 'Mozilla/4.0 (compatible; MSIE 5.5; Windows NT)'
headers = { 'User-Agent' : user_agent }

try:
	params = urllib.urlencode({'Password' : sys.argv[2], 'Name' : sys.argv[1], 'CabinetAction' : 'login'} )
except:
	print "No valid arguments supplied. Please run me as 'sipnet_checkbalance.py login password'"
	sys.exit()

req = urllib2.Request("https://customer.sipnet.ru/cabinet/",params,headers)

try:
	response = urllib2.urlopen(req)
	pureHtml = response.read()
except:
	print "Can't connect to https://customer.sipnet.ru/cabinet/"
	sys.exit()


endIndex = pureHtml.find('&nbsp;<span style="font-size: 80%">')
startIndex = pureHtml.rfind('<div>',0, endIndex)
balance = pureHtml[startIndex+5:endIndex]
try:
	float(balance)
	print balance;
except:
	print "No valid balance string found. Sipnet html changed or login/password is incorrect"
	sys.exit()
