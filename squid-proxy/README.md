# Squid-Terraform

Terraform module to create squid proxy on AWS 

## Usage

Clone the repository:

    $ git clone https://github.com/mohtork/terraform.git  && cd squid-proxy

Edit squid.tfvars file:

    $ vim squid.tfvars 

Initiate terraform apply:

    $ terraform init && terraform apply

## Inputs


 Inputs                    | Description
---------------------------|----------------------------------------------------------------------------------------
 `prefix`                  | any chosen name
 `region`                  | AWS region
 `image_id`                | The custom AWS AMI ID
 `instance_type`           | EC2 Instance type
 `key_name`                | The name of AWS key pairs 
 `shutdown_behavior`       | It could be stop/terminate
 `subnets`                 | subnets AZs and their CIDR
 `desired_capacity`        | The number of Amazon EC2 instances that should be running in the group
 `max_size`                | The maximum size of the autoscale group
 `min_size`                | The minimum size of the autoscale group 



### Requirments

(Optional) You can build Squid AWS AMI from https://github.com/mohtork/packer/tree/master/squid 

