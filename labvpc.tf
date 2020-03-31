variable "address" {
  type = string
}

data "template_file" "ansible_vars" {
  template = "${file("templates/ansible_vars.yaml.tpl")}"
  vars = {
    vpc_id = aws_vpc.homelab.id
    vpn_id = aws_vpn_connection.homelab.id
    tunnel1_address = aws_vpn_connection.homelab.tunnel1_address
    tunnel1_preshared_key = aws_vpn_connection.homelab.tunnel1_preshared_key
    tunnel1_vgw_inside_address = aws_vpn_connection.homelab.tunnel1_vgw_inside_address
    tunnel1_cgw_inside_address = aws_vpn_connection.homelab.tunnel1_cgw_inside_address
    tunnel1_bgp_asn = aws_vpn_connection.homelab.tunnel1_bgp_asn
    bgp_asn = aws_customer_gateway.homelab.bgp_asn
    tunnel2_address = aws_vpn_connection.homelab.tunnel2_address
    tunnel2_preshared_key = aws_vpn_connection.homelab.tunnel2_preshared_key
    tunnel2_vgw_inside_address = aws_vpn_connection.homelab.tunnel2_vgw_inside_address
    tunnel2_cgw_inside_address = aws_vpn_connection.homelab.tunnel2_cgw_inside_address
    tunnel2_bgp_asn = aws_vpn_connection.homelab.tunnel2_bgp_asn
  }
}

resource "local_file" "ansible_vars" {
  content  = data.template_file.ansible_vars.rendered
  filename = "vars/ansible_vars.yaml"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_vpc" "homelab" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name        = "Home Lab VPC"
    Environment = "Lab"
  }
}

resource "aws_customer_gateway" "homelab" {
  bgp_asn    = 65000
  ip_address = var.address
  type       = "ipsec.1"

  tags = {
    Name        = "Home Lab Cu GW"
    Environment = "Lab"
  }
}

resource "aws_vpn_gateway" "homelab" {
  vpc_id          = aws_vpc.homelab.id
  amazon_side_asn = 64512

  tags = {
    Name        = "Home Lab VPN GW"
    Environment = "Lab"
  }
}

resource "aws_vpn_connection" "homelab" {
  vpn_gateway_id      = aws_vpn_gateway.homelab.id
  customer_gateway_id = aws_customer_gateway.homelab.id
  type                = "ipsec.1"

  tags = {
    Name        = "Home Lab VPN"
    Environment = "Lab"
  }
}

resource "aws_vpn_gateway_route_propagation" "homelab" {
  vpn_gateway_id = aws_vpn_gateway.homelab.id
  route_table_id = aws_vpc.homelab.default_route_table_id
}