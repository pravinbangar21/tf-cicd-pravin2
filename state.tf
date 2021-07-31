
terraform {
  backend "s3" {
    bucket = "tf-cicd-state-p21"

    encrypt = true
    key = "terraform.tfstate"
    region = "us-east-1"
  }
}
