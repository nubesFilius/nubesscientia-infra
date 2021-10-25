terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=3.63.0"
    }
  }
  # backend "s3" {
  #   bucket = module.Storage.s3_backend
  #   key    = "path/to/my/key"
  #   region = "us-east-1"
  # }
}

provider "aws" {
  region = "us-east-1"
}

resource "random_pet" "table_name" {}

module "iam_user" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-user"
  version                       = "~> 4.3"
  name                          = "TFAdmin"
  force_destroy                 = true
  create_iam_user_login_profile = false
  create_iam_access_key         = true
  password_reset_required       = false
}

module "iam_group_superadmins" {
  source = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"

  name = "terraform-admins"
  group_users = [
    module.iam_user.iam_user_name
  ]
  custom_group_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess",
  ]
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  bucket = "tf-backend-${random_pet.table_name.id}"
  acl    = "private"
  versioning = {
    enabled = true
  }
}

# module "zone" {
#   source  = "terraform-aws-modules/route53/aws//modules/zones"
#   version = "~> 2.0"

#   zones = {
#     "nubesscientia.com" = {
#       comment = "nubesscientia.com (production)"
#       tags = {
#         website = "nubesscientia"
#       }
#     }
#   }
# }

module "Static-Website" {
  source                  = "./Static-Website"
  website-domain-main     = "nubesscientia.com"
  website-domain-redirect = "www.nubesscientia.com"
}
