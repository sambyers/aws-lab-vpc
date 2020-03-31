custgw_address: copy-asa-interface-facts.yaml
	ansible-playbook copy-asa-interface-facts.yaml
parse_custgw_address: scripts/address-parse.py vars/custgw_address.json
	python scripts/address-parse.py
aws_vpn: labvpc.tf
	terraform apply -var-file=vars/custgw_address.json
asa_vpn: asa-s2s-vpn.yaml
	ansible-playbook asa-s2s-vpn.yaml
labvpc: custgw_address parse_custgw_address aws_vpn asa_vpn
rm_aws_vpn: labvpc.tf
	terraform destroy -var-file=vars/custgw_address.json
rm_asa_vpn: rollback-asa-s2s-vpn.yaml
	ansible-playbook rollback-asa-s2s-vpn.yaml
rm_vars:
	rm vars/custgw_address.json
clean: rm_asa_vpn rm_aws_vpn rm_vars