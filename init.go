package sharedpw

import (
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/kms"
	"log"
	"os"
)

var (
	Region = `us-east-1`
	AwsSession  = session.Must(session.NewSession(&aws.Config{Region: aws.String(Region)}))
	KMS = kms.New(AwsSession)
	AwsAccount  = `820149708544`
	KmsKeyId    string
	Application = `sharedpw`
)

// Headers are added to all outgoing responses from lambda
var Headers = map[string]string{
	`Content-Type`:                     `application/json`,
	`Cache-Control`:                    `max-age = 0, private, must-revalidate, no-store`,
	`Pragma`:                           `no-cache`,
	`X-Content-Type-Options`:           `nosniff`,
	`X-Frame-Options`:                  `DENY`,
	`X-Xss-Protection`:                 `1; mode = block`,
	`Strict-Transport-Security`:        `max-age = 31536000`,
}

func init() {
	log.SetFlags(log.Lshortfile|log.LstdFlags|log.LUTC)

	switch os.Getenv("CORS") {
	case "":
		log.Fatal("Need CORS env var for access-control-allow-origin header")
	default:
		Headers["Access-Control-Allow-Origin"] = os.Getenv("CORS")
	}

	switch os.Getenv("KMS") {
	case "":
		log.Fatal("need KMS key to use, set the KMS env var.")
	default:
		KmsKeyId = os.Getenv("KMS")
	}
}

