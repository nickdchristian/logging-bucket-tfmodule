output "bucket_name" {
  description = "Name of the logging bucket."
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN of the logging bucket."
  value       = aws_s3_bucket.this.arn
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic that publishes if an object has been deleted in the logging bucket"
  value       = aws_sns_topic.this.arn
}