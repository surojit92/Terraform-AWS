resource "aws_vpn_gateway" "vpn_gateway" {
  vpc_id = aws_vpc.my_vpc.id

  tags= {
      Name = "Test VPN Gateway"
  }
}

resource "aws_customer_gateway" "customer_gateway" {
  bgp_asn    = 65000
  ip_address = "54.224.106.155"
  type       = "ipsec.1"

  tags= {
      Name = "Test Customer Gateway"
  }
}

resource "aws_vpn_connection" "vpn_conn" {
  vpn_gateway_id      = aws_vpn_gateway.vpn_gateway.id
  customer_gateway_id = aws_customer_gateway.customer_gateway.id
  type                = "ipsec.1"
  static_routes_only  = true
  

  tags= {
      Name= "Site-to-Site Connection"
  }
}

resource "aws_vpn_connection_route" "office" {
  destination_cidr_block = "10.5.0.0/16"
  vpn_connection_id      = aws_vpn_connection.vpn_conn.id
}
resource "aws_route_table" "vpn_route" {
    vpc_id = aws_vpc.my_vpc.id
    route {
    cidr_block = "0.0.0.0/0"               # Traffic from Public Subnet reaches Internet via Internet Gateway
    gateway_id = aws_internet_gateway.gw.id
     }
    tags= {
        Name = "VPN route table"
    }
}
resource "aws_vpn_gateway_route_propagation" "Test" {
  vpn_gateway_id      = aws_vpn_gateway.vpn_gateway.id
  route_table_id      = aws_route_table.vpn_route.id
}