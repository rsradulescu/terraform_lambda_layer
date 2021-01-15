provider "aws" {
  region = "us-east-1"
}

#-----------------------------------------------------
# Lambda function
# Example with a deployment package: ZIP file
#-----------------------------------------------------
data "archive_file" "localfile_hello_lambda" {
  type        = "zip"
  source_file = "functions/001_localfile_lambda/app.py"
  output_path = "functions/001_localfile_lambda/app.py.zip"
}

resource "aws_lambda_function" "lambda_function_example_layer" {
  function_name     = "example_layer_lambda"
  filename          = data.archive_file.localfile_hello_lambda.output_path
  source_code_hash  = data.archive_file.localfile_hello_lambda.output_base64sha256
  role              = aws_iam_role.iam_for_lambdatest.arn
  layers            = [aws_lambda_layer_version.lambda_numpy_layer.arn]
  handler           = "app.lambda_handler"
  runtime           = "python3.8"
  timeout           = 600
}

#------------------------------------------------------
# Lambda Layer Version

# --- Steps to create a layer zip:
# 1) cd layers
# 2) pip3 install numpy -t python
# 3) zip -r pachake.zip .
# 4) rm -R python/
#------------------------------------------------------

resource "aws_lambda_layer_version" "lambda_numpy_layer" {
  filename            = "numpy.zip"
  layer_name          = "lambda_layer_numpy"
  compatible_runtimes = ["python3.7", "python3.8"]
}

#------------------------------------------------------
# IAM role - policy - policy_attachment
#------------------------------------------------------
resource "aws_iam_role" "iam_for_lambdatest" {
  name = "iam_role_lambdatest"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}
