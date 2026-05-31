variable "aws_region" {
  type    = string
  default = "ap-northeast-2"
}

variable "frontend_bucket_name" {
  type    = string
  default = "choesuna-terraform-s3-bucket"
}

variable "terraform_state_bucket_name" {
  type    = string
  default = "choesuna-terraform-state"
}
