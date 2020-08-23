resource "aws_iam_role" "lambda_view_role" {
  name = "lambda_${var.app_name}_view_role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role" "lambda_save_role" {
  name = "lambda_${var.app_name}_save_role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "lambda_view_policy" {
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Decrypt",
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt",
        "kms:GetKeyPolicy",
        "kms:DescribeKey"
      ],
      "Resource": "${aws_kms_alias.alias.target_key_arn}"
    },
    {
      "Sid": "ReadAnddelete",
      "Effect": "Allow",
      "Action": [
        "dynamodb:DescribeTable",
        "dynamodb:GetItem",
        "dynamodb:DeleteItem",
        "dynamodb:Query"
      ],
      "Resource": [
        "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${aws_dynamodb_table.dynamodb_table.name}"
      ]
    },
    {
      "Sid": "ListTable",
      "Effect": "Allow",
      "Action": "dynamodb:ListTables",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "logs:CreateLogGroup",
      "Resource": "arn:aws:logs:${var.region}:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:${var.region}:*:log-group:/aws/lambda/lambda_${var.app_name}_view:*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_save_policy" {
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Encrypt",
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:GetKeyPolicy",
        "kms:DescribeKey"
      ],
      "Resource": "${aws_kms_alias.alias.target_key_arn}"
    },
    {
      "Sid": "Write",
      "Effect": "Allow",
      "Action": [
        "dynamodb:BatchWriteItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DescribeTable"
      ],
      "Resource": [
        "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${aws_dynamodb_table.dynamodb_table.name}"
      ]
    },
    {
      "Sid": "ListTable",
      "Effect": "Allow",
      "Action": [
        "dynamodb:ListTables",
        "kms:GenerateRandom"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "logs:CreateLogGroup",
      "Resource": "arn:aws:logs:${var.region}:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:${var.region}:*:log-group:/aws/lambda/lambda_${var.app_name}_save:*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_view_attachment" {
  policy_arn = aws_iam_policy.lambda_view_policy.arn
  role       = aws_iam_role.lambda_view_role.id
}

resource "aws_iam_role_policy_attachment" "lambda_save_attachment" {
  policy_arn = aws_iam_policy.lambda_save_policy.arn
  role       = aws_iam_role.lambda_save_role.id
}
