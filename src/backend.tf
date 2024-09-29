terraform {
  backend "s3" {
    bucket = "tech-challenge-fase-3-terraform"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}
