variable "region" {
  description = "AWS region for instance deployment"
}

# export TF_VAR_aws_profile=
variable "aws_profile" {
  description = "AWS profile name.\nFor more info check https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html"
}

variable "environment" {
  default = "prod"
}

variable "app_name" {
  description = "Application name"
  default = "ephemera"
}

variable "bucket_name" {
  description = "Name of an S3 bucket in website mode.\nIf you plan to proxy it through Cloudflare, bucket name must match FQDN of the DNS record.\nhttps://support.cloudflare.com/hc/en-us/articles/360037983412-Configuring-an-Amazon-Web-Services-static-site-to-use-Cloudflare\nThis is also needed to confiure CORS."
}

variable "scheme" {
  description = "http|https\nIf you plan to use ephemera purely through S3 website, put http."
}

