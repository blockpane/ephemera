data "local_file" "view" {
    filename = "${path.module}/view.zip"
}

data "local_file" "save" {
    filename = "${path.module}/save.zip"
}

resource "aws_lambda_function" "lambda_view" {
  filename         = data.local_file.view.filename
  function_name    = "lambda_${var.app_name}_view"
  role             = aws_iam_role.lambda_view_role.arn
  handler          = "main"
  description      = "Lambda for /view endpoint with read access to DynamoDB"

  runtime     = "go1.x"
  timeout     = 600 # 10 minutes

  environment {
    variables = {
      CORS = "${var.scheme}://${var.bucket_name}"
      KMS = aws_kms_key.key.key_id
      REGION = var.region
      ACCOUNT = data.aws_caller_identity.current.account_id
      APPLICATION = var.app_name
    }
  }
}

resource "aws_lambda_function" "lambda_save" {
  filename         = data.local_file.save.filename
  function_name    = "lambda_${var.app_name}_save"
  role             = aws_iam_role.lambda_save_role.arn
  handler          = "main"
  description      = "Lambda for /save endpoint with read/write access to DynamoDB"

  runtime     = "go1.x"
  timeout     = 600 # 10 minutes

  environment {
    variables = {
      CORS = "${var.scheme}://${var.bucket_name}"
      KMS = aws_kms_key.key.key_id
      REGION = var.region
      ACCOUNT = data.aws_caller_identity.current.account_id
      APPLICATION = var.app_name
    }
  }
}
