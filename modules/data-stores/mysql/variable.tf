variable "db_password" {
  description = "The password for the database"
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


