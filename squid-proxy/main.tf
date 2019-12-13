# create squid vpc
resource "aws_vpc" "squid_vpc"  {
    cidr_block           = var.vpc_cidr
    enable_dns_hostnames = true

    tags = {
        Name = "squid-proxy-vpc"
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
        Name = "squid-igw"
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
       Name = "squid-rt"
   } 
}

# Associate route table to public subnets
resource "aws_route_table_association" "squid_public_subnet" {
    count = length(var.subnets)

    subnet_id = element(aws_subnet.public_subnet.*.id, count.index)
    route_table_id = aws_route_table.squid-rt-public.id
}

# Create Network Load Balancer
resource "aws_lb" "squid-lb" {
    name               = var.prefix
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
    name     = var.prefix
    port     = 3128
    protocol = "TCP"
    vpc_id   = aws_vpc.squid_vpc.id
}

# Launch Autoscaling Configuration
resource "aws_launch_template" "squid-as-lc" {
    name_prefix                          = var.prefix
    image_id                             = var.image_id
    instance_type                        = var.instance_type
    key_name                             = var.key_name
    instance_initiated_shutdown_behavior = var.shutdown_behavior
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
    availability_zones   = aws_subnet.public_subnet.*.availability_zone
    vpc_zone_identifier  = aws_subnet.public_subnet.*.id
    desired_capacity     = var.desired_capacity
    max_size             = var.max_size
    min_size             = var.min_size
    target_group_arns    = [aws_lb_target_group.squid-tg.arn]
    launch_template {
        id      = aws_launch_template.squid-as-lc.id
    }
}





