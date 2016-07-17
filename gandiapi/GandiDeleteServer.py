#!/usr/bin/python3
# -*- coding: utf-8 -*-

import pprint
import xmlrpc.client
import sys
import time 
from time import gmtime, strftime
import urllib.parse
import urllib.request
import os
import subprocess

pp = pprint.PrettyPrinter(indent=4)

pp.pprint("Python: GandiDeleteServer")

# Parameters
hostname = sys.argv[1]


# API production connection
api = xmlrpc.client.ServerProxy('https://rpc.gandi.net/xmlrpc/')


# API key
apikey = ''

print("*****************************************************")
print("List of Virtual Machine")

vmList = api.hosting.vm.list(apikey)
#pp.pprint(vmList)


for vm in vmList:
    # Get the vm
    vm_id = vm['id']
    vm_hostname = vm['hostname']
    pp.pprint(str(vm_id) + " " + vm_hostname)


    if vm_hostname == hostname:
        vmInfo =  api.hosting.vm.info(apikey, vm_id)

        # Delete the vm
        print("  vm deletetion in progress")

        print("  vm stop:" + vm_hostname)
        vmStop = api.hosting.vm.stop(apikey, vm_id)
        pp.pprint("    ope:" + str(vmStop['id']) + ":" + vmStop['step'])
        

        # TODO: Replace by 'step' checker
        time.sleep(60)

     
        # Get operation information
        opeInfo = api.operation.info(apikey, vmStop['id'])
        pp.pprint("    ope:" + str(opeInfo['id']) + ":" + opeInfo['step'])
       

        # When 'Stop' operation step if done/finished
        if opeInfo['step'] == "DONE":
            print("  vm delete:" + vm_hostname)
            vmDelete = api.hosting.vm.delete(apikey, vm_id)

            pp.pprint("    ope:" + str(vmDelete['id']) + ":" + vmDelete['step'])

            # TODO: Replace by 'step' checker
            time.sleep(60)

            # Get operation information
            opeInfo = api.operation.info(apikey, vmDelete['id'])
        
            # When 'Delete' operation step if done/finished
            if opeInfo['step'] == "DONE":
                pp.pprint("    ope:" + str(opeInfo['id']) + ":" + opeInfo['step'])


print("*****************************************************")
sys.exit(0)
