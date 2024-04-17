terraform {
  backend "s3" {
    profile = "sleonov-green"
    region  = "us-east-1"
    key     = "cloud-gurus/tf-class/provisioner-1/terraform.tfstate"
    bucket  = "terraform-state.green.unixlabs.us"
  }
}
