# AI Usage Collect - Main Terraform Configuration
# Provisions infrastructure for the AI coding tool usage tracking system
# Target: AWS eu-west-1, your-aws-profile account

locals {
  name_prefix = "ai-usage"
}

# S3 Usage Bucket with lifecycle policy
resource "aws_s3_bucket" "usage_events" {
  bucket = "${local.name_prefix}-events-${var.account_id}"
  tags   = { Name = "${local.name_prefix}-events" }
}

resource "aws_s3_bucket_versioning" "usage_events" {
  bucket = aws_s3_bucket.usage_events.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_lifecycle_configuration" "usage_events" {
  bucket = aws_s3_bucket.usage_events.id
  rule {
    id     = "transition-and-expire"
    status = "Enabled"
    filter {}
    transition { days = 90; storage_class = "STANDARD_IA" }
    expiration { days = 365 }
  }
}

resource "aws_s3_bucket_public_access_block" "usage_events" {
  bucket                  = aws_s3_bucket.usage_events.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Ingestion Lambda
resource "aws_iam_role" "lambda_ingestion" {
  name = "${local.name_prefix}-lambda-ingestion"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole"; Effect = "Allow"; Principal = { Service = "lambda.amazonaws.com" } }]
  })
  tags = { Name = "${local.name_prefix}-lambda-ingestion" }
}

resource "aws_iam_role_policy" "lambda_s3_write" {
  name = "${local.name_prefix}-lambda-s3-write"
  role = aws_iam_role.lambda_ingestion.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Effect = "Allow"; Action = "s3:PutObject"; Resource = "${aws_s3_bucket.usage_events.arn}/*" }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_ingestion.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/.build/lambda.zip"
}

resource "aws_lambda_function" "ingestion" {
  function_name    = "${local.name_prefix}-ingestion"
  role             = aws_iam_role.lambda_ingestion.arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.12"
  timeout          = 10
  memory_size      = 128
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  environment { variables = { USAGE_BUCKET = aws_s3_bucket.usage_events.id } }
  tags = { Name = "${local.name_prefix}-ingestion" }
}

# API Gateway
resource "aws_api_gateway_rest_api" "usage_api" {
  name        = "${local.name_prefix}-api"
  description = "AI Usage Collection API"
  tags        = { Name = "${local.name_prefix}-api" }
}

resource "aws_api_gateway_resource" "usage" {
  rest_api_id = aws_api_gateway_rest_api.usage_api.id
  parent_id   = aws_api_gateway_rest_api.usage_api.root_resource_id
  path_part   = "usage"
}

resource "aws_api_gateway_method" "usage_post" {
  rest_api_id      = aws_api_gateway_rest_api.usage_api.id
  resource_id      = aws_api_gateway_resource.usage.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "lambda_proxy" {
  rest_api_id             = aws_api_gateway_rest_api.usage_api.id
  resource_id             = aws_api_gateway_resource.usage.id
  http_method             = aws_api_gateway_method.usage_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.ingestion.invoke_arn
}

resource "aws_api_gateway_deployment" "prod" {
  rest_api_id = aws_api_gateway_rest_api.usage_api.id
  depends_on  = [aws_api_gateway_integration.lambda_proxy]
  lifecycle { create_before_destroy = true }
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.prod.id
  rest_api_id   = aws_api_gateway_rest_api.usage_api.id
  stage_name    = "prod"
  tags          = { Name = "${local.name_prefix}-api-prod" }
}

resource "aws_api_gateway_api_key" "usage_key" {
  name  = "${local.name_prefix}-api-key"
  value = var.api_key_value
}

resource "aws_api_gateway_usage_plan" "usage_plan" {
  name = "${local.name_prefix}-usage-plan"
  api_stages { api_id = aws_api_gateway_rest_api.usage_api.id; stage = aws_api_gateway_stage.prod.stage_name }
  throttle_settings { burst_limit = 100; rate_limit = 50 }
  tags = { Name = "${local.name_prefix}-usage-plan" }
}

resource "aws_api_gateway_usage_plan_key" "usage_plan_key" {
  key_id        = aws_api_gateway_api_key.usage_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.usage_plan.id
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ingestion.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.usage_api.execution_arn}/*/*"
}

# Glue Crawler and Data Catalog
resource "aws_glue_catalog_database" "usage_db" {
  name = "ai_usage_db"
}

resource "aws_iam_role" "glue_crawler" {
  name = "${local.name_prefix}-glue-crawler"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole"; Effect = "Allow"; Principal = { Service = "glue.amazonaws.com" } }]
  })
  tags = { Name = "${local.name_prefix}-glue-crawler" }
}

resource "aws_iam_role_policy" "glue_s3_read" {
  name = "${local.name_prefix}-glue-s3-read"
  role = aws_iam_role.glue_crawler.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Effect = "Allow"; Action = ["s3:GetObject", "s3:ListBucket"]; Resource = [aws_s3_bucket.usage_events.arn, "${aws_s3_bucket.usage_events.arn}/*"] }]
  })
}

resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue_crawler.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_glue_crawler" "usage_events" {
  name          = "${local.name_prefix}-crawler"
  role          = aws_iam_role.glue_crawler.arn
  database_name = aws_glue_catalog_database.usage_db.name
  table_prefix  = "usage_events"
  schedule      = "cron(0 * * * ? *)"
  s3_target { path = "s3://${aws_s3_bucket.usage_events.id}/" }
  configuration = jsonencode({ Version = 1.0; Grouping = { TableGroupingPolicy = "CombineCompatibleSchemas" } })
  tags = { Name = "${local.name_prefix}-crawler" }
}

# Athena
resource "aws_s3_bucket" "athena_results" {
  bucket = "${local.name_prefix}-athena-results-${var.account_id}"
  tags   = { Name = "${local.name_prefix}-athena-results" }
}

resource "aws_s3_bucket_public_access_block" "athena_results" {
  bucket                  = aws_s3_bucket.athena_results.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_athena_workgroup" "analytics" {
  name = "${local.name_prefix}-analytics"
  configuration { result_configuration { output_location = "s3://${aws_s3_bucket.athena_results.id}/results/" } }
  tags = { Name = "${local.name_prefix}-analytics" }
}

resource "aws_athena_named_query" "usage_by_team" {
  name      = "usage_by_team"
  workgroup = aws_athena_workgroup.analytics.name
  database  = aws_glue_catalog_database.usage_db.name
  query     = "SELECT team, COUNT(*) as event_count, SUM(session_credits) as total_credits FROM usage_events GROUP BY team ORDER BY total_credits DESC"
}

resource "aws_athena_named_query" "usage_by_category" {
  name      = "usage_by_category"
  workgroup = aws_athena_workgroup.analytics.name
  database  = aws_glue_catalog_database.usage_db.name
  query     = "SELECT category, COUNT(*) as event_count, SUM(session_credits) as total_credits FROM usage_events GROUP BY category ORDER BY event_count DESC"
}

resource "aws_athena_named_query" "daily_trends" {
  name      = "daily_trends"
  workgroup = aws_athena_workgroup.analytics.name
  database  = aws_glue_catalog_database.usage_db.name
  query     = "SELECT DATE(timestamp) as day, COUNT(*) as event_count, SUM(session_credits) as total_credits FROM usage_events GROUP BY DATE(timestamp) ORDER BY day DESC LIMIT 30"
}
