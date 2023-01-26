output "dynamodb" {
  description = "DynamoDB table"
  value       = aws_dynamodb_table.create_dynamodb
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.create_dynamodb.arn
}

output "dynamodb_table_id" {
  description = "ID of the DynamoDB table"
  value       = aws_dynamodb_table.create_dynamodb.id
}

output "dynamodb_table_stream_arn" {
  description = "The ARN of the Table Stream. Only available when var.stream_enabled is true"
  value       = try(aws_dynamodb_table.create_dynamodb.stream_arn, null)
}

output "dynamodb_table_stream_label" {
  description = "A timestamp, in ISO 8601 format of the Table Stream. Only available when var.stream_enabled is true"
  value       = try(aws_dynamodb_table.create_dynamodb.stream_label, null)
}
