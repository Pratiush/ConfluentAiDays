# AWS Lambda for processing doctor prescriptions and generating lifestyle recommendations

data "aws_region" "current" {}

# IAM Role for Lambda
resource "aws_iam_role" "health_lambda_role" {
  name = "health-recommendation-lambda-role-${random_string.suffix.result}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Lambda
resource "aws_iam_role_policy" "health_lambda_policy" {
  name = "health-lambda-policy"
  role = aws_iam_role.health_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ]
        Resource = "*"
      }
    ]
  })
}

# Lambda function code
resource "local_file" "lambda_code" {
  content = templatefile("${path.module}/lambda_function.py.tpl", {
    kafka_bootstrap_servers = confluent_kafka_cluster.health_cluster.bootstrap_endpoint
    kafka_username         = confluent_api_key.health_api_key.id
    kafka_password         = confluent_api_key.health_api_key.secret
    aws_region            = var.aws_region
  })
  filename = "${path.module}/lambda_function.py"
}

# Package Lambda function
data "archive_file" "health_lambda_zip" {
  type        = "zip"
  source_file = local_file.lambda_code.filename
  output_path = "${path.module}/health_lambda.zip"
  depends_on  = [local_file.lambda_code]
}

# Lambda function
resource "aws_lambda_function" "health_processor" {
  filename         = data.archive_file.health_lambda_zip.output_path
  function_name    = "health-lifestyle-processor-${random_string.suffix.result}"
  role            = aws_iam_role.health_lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  runtime         = "python3.11"
  timeout         = 300
  source_code_hash = data.archive_file.health_lambda_zip.output_base64sha256

  environment {
    variables = {
      KAFKA_BOOTSTRAP_SERVERS = confluent_kafka_cluster.health_cluster.bootstrap_endpoint
      KAFKA_USERNAME         = confluent_api_key.health_api_key.id
      KAFKA_PASSWORD         = confluent_api_key.health_api_key.secret
      BEDROCK_REGION         = var.aws_region
      RECOMMENDATIONS_TOPIC  = "lifestyle-recommendations"
      REMINDERS_TOPIC       = "medicine-reminders"
    }
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "health_lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.health_processor.function_name}"
  retention_in_days = 7
} 