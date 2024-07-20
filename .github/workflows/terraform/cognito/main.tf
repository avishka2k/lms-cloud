terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.58.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_cognito_user_pool" "lms_cognito" {
  name                = "lms-cognito-users2"
#   deletion_protection = "ACTIVE"

  password_policy {
    minimum_length                   = 8
    require_uppercase                = true
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    temporary_password_validity_days = 7
  }

  schema {
    name                     = "address"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = false
    string_attribute_constraints {
      min_length = "0"
      max_length = "2048"
    }
  }

  schema {
    name                     = "birthdate"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = false
    string_attribute_constraints {
      min_length = "10"
      max_length = "10"
    }
  }

  schema {
    name                     = "gender"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = false
    string_attribute_constraints {
      min_length = "0"
      max_length = "2048"
    }
  }

  schema {
    name                     = "picture"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = false
    string_attribute_constraints {
      min_length = "0"
      max_length = "2048"
    }
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
    name                     = "phone_number"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = false
    string_attribute_constraints {
      min_length = "0"
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
  domain       = "lms2"
  user_pool_id = aws_cognito_user_pool.lms_cognito.id
}

data "aws_caller_identity" "current" {}

resource "aws_cognito_user_group" "cognito_group1" {
  name         = "ADMIN"
  description  = "LMS Super user"
  precedence   = 0
  role_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/service-role/lms-cognito-user-pool"
  user_pool_id = aws_cognito_user_pool.lms_cognito.id
}

resource "aws_cognito_user_group" "cognito_group2" {
  name         = "LECTURER"
  description  = "LMS Lecturer"
  precedence   = 0
  role_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/service-role/lms-cognito-user-pool"
  user_pool_id = aws_cognito_user_pool.lms_cognito.id
}

resource "aws_cognito_user_group" "cognito_group3" {
  name         = "STUDENT"
  description  = "LMS Students"
  precedence   = 0
  role_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/service-role/lms-cognito-user-pool"
  user_pool_id = aws_cognito_user_pool.lms_cognito.id
}

resource "aws_cognito_user_pool_client" "cognito_client" {
  name                         = "lms-app-client"
  user_pool_id                 = aws_cognito_user_pool.lms_cognito.id
  generate_secret              = true
  allowed_oauth_flows          = ["code"]
  explicit_auth_flows          = ["ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_PASSWORD_AUTH", "ALLOW_USER_SRP_AUTH"]
  allowed_oauth_scopes         = ["email", "openid", "phone"]
  callback_urls                = ["http://localhost:8081", "http://localhost:8081/login/oauth2/code/cognito", "https://oauth.pstmn.io/v1/callback"]
  supported_identity_providers = ["COGNITO"]
}
