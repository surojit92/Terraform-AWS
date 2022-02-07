resource "aws_security_group" "my_lb" {
  name        = "LB_SG"
  description = "Allow HTTP/HTTPS traffic to instances through Load Balancer"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow HTTP/HTTPS through LB Security Group"
  }
}

resource "aws_elb" "web_elb" {
  name = "web-elb"
  security_groups = ["${aws_security_group.my_lb.id}", "${aws_security_group.my_sg.id}"]
  subnets = [aws_subnet.public_subnet_1a.id, aws_subnet.public_subnet_1a.id]

  cross_zone_load_balancing   = true

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:80/"
  }

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "80"
    instance_protocol = "http"
  }
}

/*resource "aws_instance" "bastion" {
  key_name      = "irap_key"
  ami           = "ami-0af25d0df86db00c1"
  instance_type = "t3.medium"
  associate_public_ip_address = true
  subnet_id = aws_subnet.public_subnet.id
  vpc_security_group_ids = ["${aws_security_group.my_lb.id}"]

  tags = {
    Name = "test_EC2"
  }
}*/

