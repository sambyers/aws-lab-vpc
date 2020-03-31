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
- Your ASA's external or internet facing interface is named outside. This is convention anyway, but the scripts needs to be modified if you are using a different naming scheme.
- You only want internal access to instances in the VPC that is created.
- Replace ASA_MGMT_IP with the correct management IP for your ASA.
- Create a directory called vars in the cloned repo.
- I did not handle any secrets in these scripts. I'm not using vault for either Ansible or Terraform. When running the playbooks for the ASA, you will be prompted for the password. Terraform is gleaning credentials from AWS CLI configuration. You could easily change this.