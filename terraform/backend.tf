terraform {
  backend "s3" {
    bucket         = "tf-state-calculadora"
    key            = "terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
