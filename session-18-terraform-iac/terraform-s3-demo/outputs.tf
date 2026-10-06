output "bucket_id" {
  description = "The name / ID of the created S3 bucket."
  value       = aws_s3_bucket.s3_bucket.id
}

output "bucket_arn" {
  description = "The Amazon Resource Name (ARN) of the bucket."
  value       = aws_s3_bucket.s3_bucket.arn
}

output "bucket_region" {
  description = "The AWS Region where the bucket is hosted."
  value       = aws_s3_bucket.s3_bucket.region
}

output "versioning_status" {
  description = "The current versioning configuration status of the bucket."
  value       = aws_s3_bucket_versioning.versioning.versioning_configuration[0].status
}

output "bucket_domain_name" {
  description = "The bucket domain name."
  value       = aws_s3_bucket.s3_bucket.bucket_domain_name
}
