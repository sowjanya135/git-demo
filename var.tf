variable "ami" {
  description = "ID of AMI to use for the instance"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Key name of the Key Pair to use for the instance; which can be managed using the `aws_key_pair` resource"
  type        = string
  default     = null
}

variable "ingress_rules" {
  default     = {
    "description" = ["For HTTP", "For SSH"]
    "from_port"   = ["80", "22"]
    "to_port"     = ["80", "22"]
    "protocol"    = ["tcp", "tcp"]
    "cidr_blocks" = ["0.0.0.0/0", "0.0.0.0/0"]
  }
  type        = map(list(string))
  description = "Security group rules"
}