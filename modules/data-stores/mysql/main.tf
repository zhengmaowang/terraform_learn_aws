provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_db_instance" "example" {
  identifier_prefix = "terraform-up-and-running-rock"
  engine = "mysql"
  allocated_storage = 10
  instance_class = "db.t3.micro"
  
  username             = "admin"
  password             = jsondecode(data.aws_secretsmanager_secret_version.secret_credentials.secret_string)["password"]
  skip_final_snapshot = true
  
}

data "aws_secretsmanager_secret" "stage-mysql-password" {
 name = "stage-mysql-password"
}

data "aws_secretsmanager_secret_version" "secret_credentials" {
 secret_id = data.aws_secretsmanager_secret.stage-mysql-password.id
}

terraform {
  backend "s3" {
    bucket =  "terraform-aws-state-sandbox"
    key = "stage/data-stores/mysql/terraform.tfstate"
    region = "ap-southeast-2"

    dynamodb_table = "terraform-aws-locks"
    encrypt = true
  }
}

