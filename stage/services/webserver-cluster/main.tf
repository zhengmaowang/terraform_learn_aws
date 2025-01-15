provider "aws" {
  region = "ap-southeast-2"
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"
  
  cluster_name = "webservers-stage"
  db_remote_state_bucket = "terraform-aws-state-sandbox"
  db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate" 
  vpc_id = "vpc-08297bf54f8760084"
}
