terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas",
      version = "1.8.0"
    }
    confluent = {
      source = "confluentinc/confluent"
      version = "1.39.0"
    }
  }
}

provider "aws" {
    region = "eu-west-1"
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    token = var.aws_token
}

provider "mongodbatlas" {
  region = local.region
  public_key = var.mongodbatlas_public_key // ezivcqdh
  private_key  = var.mongodbatlas_private_key // 48321995-ac22-4a88-83b8-b741e93cc225
}

provider "confluent" {
  cloud_api_key    = var.confluentcloud_public_key    # optionally use CONFLUENT_CLOUD_API_KEY env var
  cloud_api_secret = var.confluentcloud_private_key 
}