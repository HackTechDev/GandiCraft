#!/usr/bin/python2.7
# -*- coding: utf-8 -*-

import urllib2
import urllib
import pprint
import xmlrpclib
import sys 
import time 
from time import gmtime, strftime
import os
import subprocess

# http://effbot.org/media/downloads/xmlrpclib-1.0.1.zip

pp = pprint.PrettyPrinter(indent=4)

pp.pprint("Python: GandiCreateServer")

# Parameters
hostname = sys.argv[1]


# API production connection
api = xmlrpclib.ServerProxy('https://rpc.gandi.net/xmlrpc/')


# API key
apikey = ''


version = api.version.info(apikey)
pp.pprint(version)


# vm specifity
vm_spec = {'datacenter_id' : 1,  
           'cores' : 1,  
           'memory' : 1024,
           'hostname' : hostname, 
           'login' : 'administrateur', 
           'password' : 'mot2passe' }


# disk specifity
disk_spec = {'datacenter_id' : 1,
             'name' : 'sysdisk' + hostname, 
             'size' : 10240}


# Id image of "Debian 8 64 bits (HVM)"
image_id = 3315704


# Create the server
vmCreate = api.hosting.vm.create_from(apikey, vm_spec, disk_spec, image_id)


#pp.pprint(vmCreate)

# Operation list
diskCreateOpe = api.operation.info(apikey, vmCreate[0]['id'])
ifaceCreateOpe = api.operation.info(apikey, vmCreate[1]['id'])
vmCreateOpe = api.operation.info(apikey, vmCreate[2]['id'])

vm_id = vmCreateOpe['params']['vm_id']


# Get the vm creation ope id
pp.pprint("vmCreateOpe : " + str(vmCreateOpe['id']))

pp.pprint("vm_id : " + str(vm_id))


vmInfo = api.hosting.vm.info(apikey, vm_id)


# Get the 1st network interface
ifaces = vmInfo['ifaces']
#pp.pprint(ifaces[0])

# Get the 1st ip address
ips = ifaces[0]['ips']

#pp.pprint(ips)


# First ipv4 address
IpAd1 = ips[0]['ip']

pp.pprint(IpAd1) 


# Send request to the Cuberite server
password_mgr = urllib2.HTTPPasswordMgrWithDefaultRealm()
top_level_url = 'http://127.0.0.1:8080/webadmin/GandiCraft/Gandi'
password_mgr.add_password(None, top_level_url, 'admin', 'admin')

handler = urllib2.HTTPBasicAuthHandler(password_mgr)
opener = urllib2.build_opener(handler)
urllib2.install_opener(opener)

headers = {"Content-type": "application/x-www-form-urlencoded",}
uri = 'http://127.0.0.1:8080/webadmin/GandiCraft/Gandi'
data = urllib.urlencode({'action': 'update', 'name': hostname, 'field': 'ipv4', 'value': IpAd1})

req = urllib2.Request(uri,data,headers)
result = urllib2.urlopen(req)
result.read()
