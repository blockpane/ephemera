# Create s3 backet
# bucket name it's a domain name
# https://support.cloudflare.com/hc/en-us/articles/360037983412-Configuring-an-Amazon-Web-Services-static-site-to-use-Cloudflare
# If proxied through Cloudflare, remove 0.0.0.0/0 line from ACL to restrict direct access to the bucket
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${var.bucket_name}/*",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": [
            "2400:cb00::/32",
            "2405:8100::/32",
            "2405:b500::/32",
            "2606:4700::/32",
            "2803:f800::/32",
            "2c0f:f248::/32",
            "2a06:98c0::/29",
            "103.21.244.0/22",
            "103.22.200.0/22",
            "103.31.4.0/22",
            "104.16.0.0/12",
            "108.162.192.0/18",
            "131.0.72.0/22",
            "141.101.64.0/18",
            "162.158.0.0/15",
            "172.64.0.0/13",
            "173.245.48.0/20",
            "188.114.96.0/20",
            "190.93.240.0/20",
            "197.234.240.0/22",
            "198.41.128.0/17",
            "0.0.0.0/0"
          ]
        }
      }
    }
  ]
}
EOF

  website {
    index_document = "index.html"
  }

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Managed_by = "Terraform"
  }
}
