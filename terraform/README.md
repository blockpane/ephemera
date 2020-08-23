### Deployment

This is a terraform manifest which will deploy Ephemera in the AWS. Below is a list of AWS components provisioned:

- S3 bucket (website mode)
- API Gateway
- Lambda functions
- DynamoDB table
- KMS symmetric key
- IAM policies and roles

Since S3 website mode requires an extra layer to enable https, there is a `cloudflare` directory where you can provision a web resource to proxy S3 bucket. Keep in mind that bucket name must match fqdn of your proxy [Example](https://support.cloudflare.com/hc/en-us/articles/360037983412-Configuring-an-Amazon-Web-Services-static-site-to-use-Cloudflare)

## How to guide

- Build Ephemera Go components by running `make build` in the root directory of Ephemera
- Copy `save.zip` and `view.zip` from `dist` direcotry to the root of this deployment
- Configure `~/.aws/credentials` profile [AWS Guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
- Run `terraform init`, `terraform plan` to see the plan
- Run `terraform apply`
- Once components are deployed, copy `base_url` value from the output of the terraform console to the `/client/example.env` file of Ephemera
- Rename `example.env` to `.env` and run `npm install`, `npm run build`
- Copy `/client/dist/` directory contents to S3 bucket root

If you set `var.scheme` to `http` when running `terraform apply`, you can try accessing Ephemera with the `s3_url` printed from the terraform console output. 

```
Apply complete! Resources: X added, 0 changed, 0 destroyed.

Outputs:

base_url = https://!randomvalue!.execute-api.eu-central-1.amazonaws.com/v1
s3_bucket = yourbucketname.your.domain
s3_url = yourbucketname.your.domain.s3-website.eu-central-1.amazonaws.com
```

If you set `var.scheme` to `https` when running `terraform apply`, you will need to setup another proxy of your choice. Cloudflare terrafrom manifest is in the `cloudflare` directory.