module "web_server_virginia" {
  source = "./modules/webserver"
  providers = {
    aws = aws.virginia
  }
}

module "web_server_oregon" {
  source = "./modules/webserver"
  providers = {
    aws = aws.oregon
  }
}
