prefix            = "squid"
region            = ""
image_id          = ""
instance_type     = "t2.small"
key_name          = ""
shutdown_behavior = "stop" 
vpc_cidr          = "10.0.0.0/16"
subnets           = {
    eu-west-1a = "10.0.1.0/24"
    eu-west-1b = "10.0.2.0/24"
    eu-west-1c = "10.0.3.0/24"
  }
# Autoscal group Variables
desired_capacity = 3
max_size         = 4
min_size         = 1

