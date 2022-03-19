variable "main" {
  default = {
    "aws_account_ids" = ["277775555339"]
    "name" = "datz"
    "route53_zone_app_name" = "datz.mspv2.com"
    "region" = "us-west-1"
    "az_1" = "us-west-1b"
    "az_2" = "us-west-1c"
    "acm_certificate_arn" = "arn:aws:acm:us-west-1:277775555339:certificate/f04d9e80-5594-4b5d-985b-3817ffa49a4e"
    "instance_type_management" = "t3.nano"
    "instance_type_app" = "t3.micro"
    "public_key_path_management" = "../../key-datz-management.pub"
    "public_key_path_app" = "../../key-datz-app.pub"
    "db_instance_type_app" = "db.t3.micro"
  }
}
