terraform {
  required_providers {
    aws  = "~> 3.74"
  }
}

provider "aws" {
  region = var.main.region
  allowed_account_ids = var.main.aws_account_ids
}

module "app" {
  source = "../../modules/app/"
  name = var.main.name
  route53_zone_app_name = var.main.route53_zone_app_name
  region = var.main.region
  az_1 = var.main.az_1
  az_2 = var.main.az_2
  instance_type_management = var.main.instance_type_management
  instance_type_app = var.main.instance_type_app
  public_key_path_management = var.main.public_key_path_management
  public_key_path_app = var.main.public_key_path_app
  acm_certificate_arn = var.main.acm_certificate_arn
  db_instance_type_app = var.main.db_instance_type_app
}
