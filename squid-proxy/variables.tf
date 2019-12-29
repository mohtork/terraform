variable "region" {
    description = "The region to deploy the VPC in"
    type        = string 
}

variable "vpc_cidr" {
    description = "The CIDR block for the VPC"
    type = string
}

variable "subnets" {
    description = "A map of availability zones to create subnet on each AZ"
    type        = map
}

variable "public_subnet_suffix" {
  description = "Suffix to append to public subnets name"
  type        = string
  default     = "public"
}

variable "prefix" {
    description = "prefix"
    type        = string
}

variable "image_id" {
    description = "squid aws ami image id"
    type        = string
}

variable "instance_type" {
    description = "EC2 type"
    type        = string
}

variable "key_name"{
    description = "ssh key name"
    type        = string
}

variable "shutdown_behavior" {
    description = "EC2 shutdown behavior"
    type        = string
    default     = "stop"
}

variable "desired_capacity" {
    description = "Autoscal group desired capacity"
    type        = number
}

variable "max_size" {
    description = "Maximum number of EC2s in Autoscale Group"
    type        = number
}

variable "min_size" {
    description = "Minimum number of EC2s in Autoscal Group"
    type        = number
}

variable "ingress_from_port" {
  description = "The start port"
  type        = number
  default     = 3128
}

variable "ingress_to_port" {
  description = "The end port"
  type        = number
  default     = 3128
}

variable "ingress_protocol" {
  description = "The protocol"
  type        = string
  default     = "tcp"
}

variable "ingress_cidr_blocks" {
  description = "List of CIDR blocks"
  type        = list
  default     = ["0.0.0.0/0"]
}

variable "egress_from_port" {
  description = "The start port"
  type        = number
  default     = 0
}

variable "egress_to_port" {
  description = "The end port"
  type        = number
  default     = 65535
}

variable "egress_protocol" {
  description = "The protocol"
  type        = string
  default     = "tcp"
}

variable "egress_cidr_blocks" {
  description = "List of CIDR blocks"
  type        = list
  default     = ["0.0.0.0/0"]
}
