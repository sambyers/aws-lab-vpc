'''
Quick and dirty script to parse output from Ansible playbook for consumption by terraform.
Parses the interface_facts from the ASA firewall down to just the outside address.
'''
import json

with open('vars/custgw_address.json', 'r') as file:
  interface_facts = json.loads(file.read())

  for intf in interface_facts:
    for k in intf.keys():
      if intf[k]['name'] == 'outside':
        output = intf[k]

with open('vars/custgw_address.json', 'w') as file:
  output.pop('name', None)
  file.write(json.dumps(output))