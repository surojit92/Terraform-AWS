###Creating Subnet for each AZ in the region
resource "aws_subnet" "rds1" {
    vpc_id                  = aws_vpc.my_vpc.id
    cidr_block              = "10.0.4.0/24"
    map_public_ip_on_launch = true
    availability_zone       = "ap-south-1a"

    tags= {
    Name = "RDS-Subnet-1"
  }
}

resource "aws_subnet" "rds2" {
    vpc_id                  = aws_vpc.my_vpc.id
    cidr_block              = "10.0.5.0/24"
    map_public_ip_on_launch = true
    availability_zone       = "ap-south-1c"

    tags= {
    Name = "RDS-Subnet-2"
  }
}

###Creating subnet group for each subnet in different az
resource "aws_db_subnet_group" "db_subnet" {
  name        = "rds-subnet-group"
  description = "Terraform example RDS subnet group"
  subnet_ids  = [aws_subnet.rds1.id, aws_subnet.rds2.id]
}

###Creating security group for rds and keeping it private
resource "aws_security_group" "rds1" {
  name        = "terraform_rds_security_group"
  description = "Terraform example RDS MySQL server"
  vpc_id      = aws_vpc.my_vpc.id
  # Keep the instance private by only allowing traffic from the web server.
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.my_sg.id}"]
  }
  
  tags= {
    Name = "terraform-example-rds1-security-group"
  }
}

/*resource "aws_security_group" "rds2" {
  name        = "terraform_rds_security_group"
  description = "Terraform example RDS MySQL server"
  vpc_id      = aws_vpc.my_vpc.id
  # Keep the instance private by only allowing traffic from the web server.
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.my_sg.id}"]
  }
  
  tags= {
    Name = "terraform-example-rds2-security-group"
  }
}*/

resource "aws_db_instance" "Test" {
  identifier              = "my-db"
  allocated_storage       = 20
  engine                  = "mysql"
  engine_version          = "8.0.23"
  instance_class          = "db.m5.large"
  publicly_accessible     = false
  name                    = "mydb"
  username                = "admin"
  password                = "Password"
  backup_retention_period = 7
  backup_window           = "09:46-10:16"
  #parameter_group_name = "default.mysql5.7"
  skip_final_snapshot     = true
  multi_az                = true
  db_subnet_group_name    = aws_db_subnet_group.db_subnet.id
  vpc_security_group_ids  = ["${aws_security_group.rds1.id}"]

  tags= {
    Name = "Test_DB"
  }
}

resource "aws_db_instance" "replica_db" {
  identifier           = "my-replica-db"
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0.23"
  instance_class       = "db.m5.large"
  publicly_accessible = false
  name                 = "mydb"
  username             = "admin"
  password             = "Password"
  #parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  replicate_source_db  = aws_db_instance.Test.id
  vpc_security_group_ids    = ["${aws_security_group.rds1.id}"]

  tags= {
    Name = "Test_DB"
  }
}