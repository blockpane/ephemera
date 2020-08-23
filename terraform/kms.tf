resource "aws_kms_key" "key" {
    description = "${var.app_name} key"
}

resource "aws_kms_alias" "alias" {
  name          = "alias/${var.app_name}-key"
  target_key_id = aws_kms_key.key.key_id
}