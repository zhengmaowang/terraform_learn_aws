output "alb_dns_name" {
  value = aws_lb.example.dns_name
  description = "The domain name of the load balancer"
}

variable "vpc_id" {
}

variable "cluster_name" {
  description = "the name to use for all the cluster resources"
  type = string
}

variable "db_remote_state_bucket" {
  description = "the name of the s3 bucket for the database's remote state"
  type = string
}

variable "db_remote_state_key" {
  description = "the path for the database's remote state in s3"
  type = string
}



