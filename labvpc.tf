# Var of External IP of FW
variable "address" {
  type = string
}
# Vars for Ansible to use when configuring our FW
data "template_file" "ansible_vars" {
  template = "${file("templates/ansible_vars.yaml.tpl")}"
  vars = {
    vpc_id = aws_vpc.lab.id
    vpn_id = aws_vpn_connection.lab.id
    tunnel1_address = aws_vpn_connection.lab.tunnel1_address
    tunnel1_preshared_key = aws_vpn_connection.lab.tunnel1_preshared_key
    tunnel1_vgw_inside_address = aws_vpn_connection.lab.tunnel1_vgw_inside_address
    tunnel1_cgw_inside_address = aws_vpn_connection.lab.tunnel1_cgw_inside_address
    tunnel1_bgp_asn = aws_vpn_connection.lab.tunnel1_bgp_asn
    bgp_asn = aws_customer_gateway.lab.bgp_asn
    tunnel2_address = aws_vpn_connection.lab.tunnel2_address
    tunnel2_preshared_key = aws_vpn_connection.lab.tunnel2_preshared_key
    tunnel2_vgw_inside_address = aws_vpn_connection.lab.tunnel2_vgw_inside_address
    tunnel2_cgw_inside_address = aws_vpn_connection.lab.tunnel2_cgw_inside_address
    tunnel2_bgp_asn = aws_vpn_connection.lab.tunnel2_bgp_asn
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

resource "aws_vpc" "lab" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name        = "Lab_VPC"
    Environment = "Lab"
  }
}

resource "aws_security_group" "lab" {
  name        = "lab default sg"
  description = "Allow SSH and ICMP"
  vpc_id      = aws_vpc.lab.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.lab.cidr_block]
  }

  ingress {
    description = "SSH from on premise network"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.168.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Lab_SG"
    Environment = "Lab"
  }
}

resource "aws_customer_gateway" "lab" {
  bgp_asn    = 65000
  ip_address = var.address
  type       = "ipsec.1"

  tags = {
    Name        = "Lab_CU_GW"
    Environment = "Lab"
  }
}

resource "aws_vpn_gateway" "lab" {
  vpc_id          = aws_vpc.lab.id
  amazon_side_asn = 64512

  tags = {
    Name        = "Lab_VPN_GW"
    Environment = "Lab"
  }
}

resource "aws_vpn_connection" "lab" {
  vpn_gateway_id      = aws_vpn_gateway.lab.id
  customer_gateway_id = aws_customer_gateway.lab.id
  type                = "ipsec.1"

  tags = {
    Name        = "Lab_VPN"
    Environment = "Lab"
  }
}

resource "aws_vpn_gateway_route_propagation" "lab" {
  vpn_gateway_id = aws_vpn_gateway.lab.id
  route_table_id = aws_vpc.lab.default_route_table_id
}