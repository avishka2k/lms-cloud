variable "aws_region" {
  description = "The AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "user_pool_name" {
  description = "The name of the user pool"
  type        = string
  default     = "lms-cognito-users"
}

variable "user_pool_domain" {
  description = "The domain of the user"
  type        = string
  default     = "lmsmicro"
}

variable "user_pool_client_name" {
  description = "The name of the user pool client"
  type        = string
  default     = "lms-app-client"
}

variable "callback_urls" {
  description = "The callback URLs"
  type        = list(string)
  default = [
    "http://localhost:8081",
    "http://localhost:8081/login/oauth2/code/cognito",
    "https://oauth.pstmn.io/v1/callback"
  ]
}

variable "cognito_admin_user_email" {
  description = "The email of the admin user"
  type        = string
  default     = "avishka2k@gmail.com"
}