terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.58.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_cognito_user_pool" "lms_cognito" {
  name                = var.user_pool_name
  deletion_protection = "ACTIVE"

  alias_attributes = ["email"]

  password_policy {
    minimum_length                   = 8
    require_uppercase                = true
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    temporary_password_validity_days = 7
  }

  schema {
    name                     = "sub"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = false
    required                 = true
    string_attribute_constraints {
      min_length = "1"
      max_length = "2048"
    }
  }

  schema {
    name                     = "email"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = true
    string_attribute_constraints {
      min_length = "0"
      max_length = "2048"
    }
  }

  schema {
    name                     = "name"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = true
    string_attribute_constraints {
      min_length = "0"
      max_length = "2048"
    }
  }

  auto_verified_attributes = ["email"]

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }

  user_attribute_update_settings {
    attributes_require_verification_before_update = ["email"]
  }

  mfa_configuration = "OFF"

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  username_configuration {
    case_sensitive = true
  }

}

resource "aws_cognito_user_pool_domain" "lms_domain" {
  domain       = var.user_pool_domain
  user_pool_id = aws_cognito_user_pool.lms_cognito.id
}

data "aws_caller_identity" "current" {}

resource "aws_cognito_user_group" "cognito_group_admin" {
  name         = "ADMIN"
  description  = "LMS Super user"
  precedence   = 0
  role_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/service-role/lms-cognito-user-pool"
  user_pool_id = aws_cognito_user_pool.lms_cognito.id
}

resource "aws_cognito_user_group" "cognito_group_lecturer" {
  name         = "LECTURER"
  description  = "LMS Lecturer"
  precedence   = 0
  role_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/service-role/lms-cognito-user-pool"
  user_pool_id = aws_cognito_user_pool.lms_cognito.id
}

resource "aws_cognito_user_group" "cognito_group_student" {
  name         = "STUDENT"
  description  = "LMS Students"
  precedence   = 0
  role_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/service-role/lms-cognito-user-pool"
  user_pool_id = aws_cognito_user_pool.lms_cognito.id
}

resource "aws_cognito_user_pool_client" "cognito_client" {
  name                                 = var.user_pool_client_name
  user_pool_id                         = aws_cognito_user_pool.lms_cognito.id
  generate_secret                      = true
  allowed_oauth_flows                  = ["code"]
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_PASSWORD_AUTH", "ALLOW_USER_SRP_AUTH"]
  allowed_oauth_scopes                 = ["email", "openid", "phone"]
  callback_urls                        = var.callback_urls
  supported_identity_providers         = ["COGNITO"]
  prevent_user_existence_errors        = "ENABLED"
  allowed_oauth_flows_user_pool_client = true
}

resource "aws_cognito_user" "cognito_admin_user" {
  user_pool_id = aws_cognito_user_pool.lms_cognito.id
  username     = "lmsadmin"
  attributes = {
    "email" = var.cognito_admin_user_email
  }
}

resource "aws_cognito_user_in_group" "cognito_admin_user_in_group" {
  user_pool_id = aws_cognito_user_pool.lms_cognito.id
  username     = aws_cognito_user.cognito_admin_user.username
  group_name   = aws_cognito_user_group.cognito_group_admin.name
}

output "user_pool_id" {
  value       = aws_cognito_user_pool.lms_cognito.id
  description = "value of the user pool id"
}