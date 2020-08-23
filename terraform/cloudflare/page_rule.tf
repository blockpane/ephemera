data "terraform_remote_state" "that" {
  backend = "local"
  config = {
    path = "${path.module}/../terraform.tfstate"
  }
}

resource "cloudflare_page_rule" "this" {
  zone_id = var.CLOUDFLARE_ZONE_ID
  target  = "${data.terraform_remote_state.that.outputs.s3_bucket}$/*"

  priority = 1
  status   = "active"
  actions {
    ssl = "flexible"
  }


}
