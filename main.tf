# VPC Creation
resource "aws_vpc" "my_vpc" {
  cidr_block       = "10.0.0.0/16" # Defining the CIDR block use 10.0.0.0/24 for demo
  instance_tenancy = "default"

  tags = {
    Name = "My_VPC"
  }
}

##IGW Creation
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "Test_IGW"
  }
}

# Public Subnet Creation
resource "aws_subnet" "public_subnet_1a" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "Public Subnet-1b"
  }
}

resource "aws_subnet" "public_subnet_1b" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.6.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "Public Subnet-1a"
  }
}

# Web app Subnet Creation
resource "aws_subnet" "web_app_1a" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "Web App Subnet 1A"
  }
}

resource "aws_subnet" "web_app_1b" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "Web App Subnet 1B"
  }
}

#Route table for Public Subnet's
 resource "aws_route_table" "PublicRT" {    # Creating RT for Public Subnet
    vpc_id =  aws_vpc.my_vpc.id
         route {
    cidr_block = "0.0.0.0/0"               # Traffic from Public Subnet reaches Internet via Internet Gateway
    gateway_id = aws_internet_gateway.gw.id
     }

    tags = {
    Name = "Pub_RT"
  } 
 }

#Route table for Private Subnet's
 resource "aws_route_table" "PrivateRT" {    # Creating RT for Private Subnet
   vpc_id = aws_vpc.my_vpc.id
   route {
   cidr_block = "0.0.0.0/0"             # Traffic from Private Subnet reaches Internet via NAT Gateway
   nat_gateway_id = aws_nat_gateway.NATgw.id
   }

   tags = {
    Name = "Priv_RT"
  } 
 }

#Public Route Association 
resource "aws_route_table_association" "PublicRTassociation1" {
    subnet_id = aws_subnet.public_subnet_1a.id
    route_table_id = aws_route_table.PublicRT.id
 }

 resource "aws_route_table_association" "PublicRTassociation2" {
    subnet_id = aws_subnet.public_subnet_1b.id
    route_table_id = aws_route_table.PublicRT.id
 }
 
 #Private Route Association
 resource "aws_route_table_association" "PrivateRTassociation1" {
    subnet_id = aws_subnet.web_app_1a.id
    route_table_id = aws_route_table.PrivateRT.id
 }

 resource "aws_route_table_association" "PrivateRTassociation2" {
    subnet_id = aws_subnet.web_app_1b.id
    route_table_id = aws_route_table.PrivateRT.id
 }

 #Create Nat IP
 resource "aws_eip" "nateIP" {
   vpc   = true
 }
 #Creating the NAT Gateway using subnet_id and allocation_id
 resource "aws_nat_gateway" "NATgw" {
   allocation_id = aws_eip.nateIP.id
   subnet_id = aws_subnet.public_subnet_1a.id
 }
