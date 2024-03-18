
locals {
  function_name               = "webdate"
  function_handler            = "${local.function_name}.lambda_handler"
  function_runtime            = "python3.9"
  function_timeout_in_seconds = 5

  function_source_dir = "${path.module}/lambda"
}

resource "aws_lambda_function" "function" {
  function_name = "${local.function_name}"
  handler       = local.function_handler
  runtime       = local.function_runtime
  timeout       = local.function_timeout_in_seconds

  filename         = "${local.function_source_dir}.zip"
  source_code_hash = data.archive_file.function_zip.output_base64sha256

  role = aws_iam_role.function_role.arn

  environment {
    variables = {
      TZ = var.timezone
      BUCKET = var.bucket_name
    }
  }
}

data "archive_file" "function_zip" {
  source_dir  = local.function_source_dir
  type        = "zip"
  output_path = "${local.function_source_dir}.zip"
}

resource "aws_iam_role" "function_role" {
  name = "${local.function_name}"
  
  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "iam_policy_for_lambda" {
 
  name         = "aws_iam_policy_for_terraform_aws_lambda_role"
  path         = "/"
  description  = "AWS IAM Policy for managing aws lambda role"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
	"Action": [
	  "s3:PutObject"
	],
	"Resource": "arn:aws:s3:::${aws_s3_bucket.bucket.id}/*",
	"Effect": "Allow"
      },
      {
	"Action": [
	  "logs:CreateLogGroup",
	  "logs:CreateLogStream",
	  "logs:PutLogEvents"
	],
	"Effect": "Allow",
	"Resource": "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
 role        = aws_iam_role.function_role.name
 policy_arn  = aws_iam_policy.iam_policy_for_lambda.arn
}

