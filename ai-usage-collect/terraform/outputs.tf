# Terraform Outputs for AI Usage Collect

output "api_endpoint" {
  description = "API Gateway endpoint URL for usage event ingestion"
  value       = "${aws_api_gateway_stage.prod.invoke_url}/usage"
}

output "api_key_value" {
  description = "API key value for authenticating requests"
  value       = aws_api_gateway_api_key.usage_key.value
  sensitive   = true
}

output "usage_bucket_name" {
  description = "S3 bucket name for usage events storage"
  value       = aws_s3_bucket.usage_events.id
}

output "usage_bucket_arn" {
  description = "S3 bucket ARN for usage events storage"
  value       = aws_s3_bucket.usage_events.arn
}

output "lambda_function_name" {
  description = "Ingestion Lambda function name"
  value       = aws_lambda_function.ingestion.function_name
}

output "glue_database_name" {
  description = "Glue catalog database name"
  value       = aws_glue_catalog_database.usage_db.name
}

output "athena_workgroup" {
  description = "Athena workgroup name for analytics queries"
  value       = aws_athena_workgroup.analytics.name
}
