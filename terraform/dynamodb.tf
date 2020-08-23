resource "aws_dynamodb_table" "dynamodb_table" {
  name           = var.app_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "secret"

  attribute {
    name = "secret"
    type = "S"
  }

  ttl {
    attribute_name = "expire"
    enabled        = true
  }

  tags = {
    Name        = "Managed by Terraform"
    Environment = "${var.environment}"
  }
}