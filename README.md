# AWS LAB VPN Automation
This repo holds the Terrform config and Ansible playbooks to bring up an AWS VPC and IPSec tunnels to a firewall.

## How to use
```
git clone https://github.com/sambyers/aws-lab-vpn
cd aws-lab-vpn
mkdir vars
pip install -r requirements.txt
ansible-galaxy install ansible-network.network-engine
```
[Install Terraform manually](https://learn.hashicorp.com/terraform/getting-started/install) or with a package manager:
```
brew install terraform # Homebrew macOS
choco install terraform # Chocolately on Windows
```

To bring up the lab VPC and VPN:
```
make labvpc
```
Now that your lab VPC is up, create instances or whatever you're labbing. You'll have private access to resources over the VPN tunnels.

To remove the lab VPC and VPN:
```
make clean
```

## Requirements
- AWS credentials for Terraform to use
- Ansible 2.9.6
- Ansible network-engine 2.7.5
- Terraform 0.12
- Make (if you're lazy like me)
- Cisco ASA 9.12
- Python 3.6+

## Assumptions
If you want to use this for your lab, there are a few assumptions made by the scripts:
- Your ASA's external or internet facing interface is named _outside_. This is convention anyway, but the scripts need to be modified if you are using a different naming scheme.
- You specifically want internal access to instances in the VPC that is created. You will have to modify the Terraform configuration if you want an EIP or public IP allocated to instances in the VPC.
- Replace ASA_MGMT_IP with the correct management IP for your ASA in the Ansible inventory.yaml file.
- You will need a directory called vars in the cloned repo. Create it with mkdir vars.
- I did not handle any secrets in these scripts. I'm not using vault for either Ansible or Terraform. When running the playbooks for the ASA, you will be prompted for the password. Terraform is gleaning credentials from AWS CLI configuration. You could easily change this to what you need.

## Details
### Making the AWS VPC and IPSec VPN lab happens in this order via the [Makefile](/blob/master/Makefile) (make labvpc):

- Ansible playbook to get interface facts from ASA. This creates a json file called custgw_address.json which contains the interface facts.
```
ansible-playbook copy-asa-interface-facts.yaml
```
- Address parsing script to create a simple json vars file with a single variable in it. It is the outside interface address of the ASA (e.g. 'address': '1.1.1.1'). This script modifies the custgw_address.json file.
```
python scripts/address-parse.py
```
- Terraform configuration applied to AWS account configured with AWS CLI. Terraform executes the instructions in labvpc.tf. The output of this configuration is vars/ansible_vars.yaml. It contains all of the vars for the IKEv1/IPSec VPN tunnels.
```
terraform apply
```
- Ansible playbook to provision ASA with IKEv1/IPSec configuration. The playbook consumes the vars/ansible_vars.yaml file for vars like IP addresses and PSKs.
```
ansible-playbook asa-s2s-vpn.yaml
```

### When using make clean, this is the order of events:
- Ansible playbook to deprovision IKEv1/IPSec configuration from the ASA. This playbook uses the vars/ansible_vars.yaml to understand the VPN state like IKEv1 attributes, PSKs, IP addresses, etc.
```
ansible-playbook rollback-asa-s2s-vpn.yaml
```
- Terraform command to destroy the configuration created earlier. Terraform keeps its own state, so no need to maintain in a file.
```
terraform destroy
```
- Remove old vars file:
```
rm vars/custgw_address.json
```

### Ansible details

### Terraform details

### Address parsing script details