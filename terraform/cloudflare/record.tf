data "terraform_remote_state" "this" {
  backend = "local"
  config = {
    path = "${path.module}/../terraform.tfstate"
  }
}

resource "cloudflare_record" "this" {
  zone_id = var.CLOUDFLARE_ZONE_ID

  name    = data.terraform_remote_state.this.outputs.s3_bucket
  type    = "CNAME"
  ttl     = "1"
  proxied = "true"
  
  value   = data.terraform_remote_state.this.outputs.s3_url
}
