## VPC 01

resource "aws_vpc" "vpc10" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = "true"
}

## VPC 02

resource "aws_vpc" "vpc20" {
    cidr_block           = "20.0.0.0/16"
    enable_dns_hostnames = "true"
}

##VPC PEERING

resource "aws_vpc_peering_connection" "vpc_peering" {
    peer_vpc_id   = aws_vpc.vpc20.id
    vpc_id        = aws_vpc.vpc10.id
    auto_accept   = true  
    tags = {
        Name = "vpc_peering"
    }
}

##SUBNET PÚBLICA

resource "aws_subnet" "subnet1a" {
    vpc_id                  = aws_vpc.vpc10.id
    cidr_block              = "10.0.5.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = "us-east-1a"
}

##SUBNET PRIVADA

resource "aws_subnet" "subnet2a" {
    vpc_id                  = aws_vpc.vpc20.id
    cidr_block              = "20.0.6.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = "us-east-1a"
}

##ROUTE TABLE

resource "aws_internet_gateway" "igw1" {
    vpc_id = aws_vpc.vpc10.id
}

resource "aws_route_table" "route" {
    vpc_id = aws_vpc.vpc10.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw1.id
    }
}

resource "aws_internet_gateway" "igw2" {
    vpc_id = aws_vpc.vpc20.id
}

resource "aws_route_table" "route" {
    vpc_id = aws_vpc.vpc20.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw2.id
    }
}

resource "aws_route_table_association" "route_association1a" {
    subnet_id      = aws_subnet.subnet1a.id
    route_table_id = aws_route_table.route.id
}

resource "aws_route_table_association" "route_association2a" {
    subnet_id      = aws_subnet.subnet2a.id
    route_table_id = aws_route_table.route.id
}


##SG

resource "aws_security_group" "sg1" {
    vpc_id = aws_vpc.vpc10.id
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["10.0.0.0/16"]
    }
    ingress {
        description = "TCP/80 from All"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "TCP/22 from All"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "sg2" {
    vpc_id = aws_vpc.vpc20.id
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["10.0.0.0/16"]
    }
    ingress {
        description = "TCP/80 from All"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "TCP/22 from All"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}