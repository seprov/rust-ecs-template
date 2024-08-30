module "primary" {
  source = "./region"
  env = var.env
  region = "us-east-1"
  app_name = var.app_name
  available_azs = data.aws_availability_zones.available
}
