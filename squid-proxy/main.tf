# create squid vpc
resource "aws_vpc" "squid_vpc"  {
    cidr_block           = var.vpc_cidr
    enable_dns_hostnames = true

    tags = {
        Name = "${var.prefix}-vpc"
    }
}

# Create public subnets
resource "aws_subnet" "public_subnet" {
    count                   = length(var.subnets)
    vpc_id                  = aws_vpc.squid_vpc.id
    cidr_block              = element(values(var.subnets), count.index)
    map_public_ip_on_launch = true
    availability_zone       = element(keys(var.subnets), count.index)

tags = merge(
    {
       "Name" = format(
       "%s-${var.public_subnet_suffix}-%s",
       var.prefix,
       element(keys(var.subnets), count.index)
      )
    },
)
}

# Create Internet GW and attache in to squid-cpv
resource "aws_internet_gateway" "squid-gw" {
    vpc_id = aws_vpc.squid_vpc.id

    tags = {
        Name = "${var.prefix}-igw"
    }
}

# Create route table
resource "aws_route_table" "squid-rt-public" {
   vpc_id = aws_vpc.squid_vpc.id

   route {
       cidr_block = "0.0.0.0/0"
       gateway_id = aws_internet_gateway.squid-gw.id
   }

   tags = {
       Name = "${var.prefix}-rt"
   } 
}

# Associate route table to public subnets
resource "aws_route_table_association" "squid_public_subnet" {
    count = length(var.subnets)

    subnet_id = element(aws_subnet.public_subnet.*.id, count.index)
    route_table_id = aws_route_table.squid-rt-public.id
}

# Create Squid Security Group
resource "aws_security_group" "squid-sg" {
    name        = "${var.prefix}-sg"
    description = "Allow Squid port"
    vpc_id      = aws_vpc.squid_vpc.id

ingress {
  from_port   = var.ingress_from_port
  to_port     = var.ingress_to_port
  protocol    = var.ingress_protocol
  cidr_blocks = var.ingress_cidr_blocks
  }

egress {
  from_port   = var.egress_from_port
  to_port     = var.egress_to_port
  protocol    = var.egress_protocol
  cidr_blocks = var.egress_cidr_blocks
}
}

# Create Network Load Balancer
resource "aws_lb" "squid-lb" {
    name               = "${var.prefix}-lb"
    internal           = false
    load_balancer_type = "network"
    subnets            = aws_subnet.public_subnet.*.id
}

# Network Load Balancer Listner
resource "aws_lb_listener" "squid-nlb" {
    depends_on        = [aws_lb_target_group.squid-tg]
    load_balancer_arn = aws_lb.squid-lb.id
    port              = 80
    protocol          = "TCP"
    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.squid-tg.arn
    }
}

resource "aws_lb_target_group" "squid-tg" {
    name     = "${var.prefix}-tg"
    port     = var.ingress_to_port
    protocol = "TCP"
    vpc_id   = aws_vpc.squid_vpc.id
}

# Launch Autoscaling Configuration
resource "aws_launch_template" "squid-as-lc" {
    name_prefix                          = "${var.prefix}-lt"
    image_id                             = var.image_id
    instance_type                        = var.instance_type
    key_name                             = var.key_name
    instance_initiated_shutdown_behavior = var.shutdown_behavior
    vpc_security_group_ids               = [aws_security_group.squid-sg.id]
    block_device_mappings {
        device_name = "/dev/xvda"
        ebs {
            volume_size = 40
            volume_type = "gp2"
            delete_on_termination = true
        }
    }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "squid-asg" {
    vpc_zone_identifier  = aws_subnet.public_subnet.*.id
    desired_capacity     = var.desired_capacity
    max_size             = var.max_size
    min_size             = var.min_size
    target_group_arns    = [aws_lb_target_group.squid-tg.arn]
    launch_template {
        id      = aws_launch_template.squid-as-lc.id
    }
}
