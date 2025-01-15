provider "aws" {
  region = "ap-southeast-2"
}

module "mysql" {
  source = "../../../modules/data-stores/mysql"
  db_remote_state_bucket = "terraform-aws-state-sandbox"
  db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate"
}
