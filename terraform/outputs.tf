# API Gateway invoke URL to be passed to ephemera .env file
output "base_url" {
  value = aws_api_gateway_deployment.deployment.invoke_url
}

# S3 website endpoint 
output "s3_url" {
  value = aws_s3_bucket.this.website_endpoint
}

# S3 bucket name to be picked by Cloudflare
output "s3_bucket" {
  value = aws_s3_bucket.this.bucket
}