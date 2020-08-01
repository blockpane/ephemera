package sharedpw

import (
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/kms"
	"log"
	"os"
)

var (
	Region string
	AwsSession *session.Session
	KMS *kms.KMS
	AwsAccount  string
	KmsKeyId    string
	Application string
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

	switch "" {
	case os.Getenv("CORS"):
		log.Fatal("Need CORS env var for access-control-allow-origin header")
	case os.Getenv("REGION"):
		log.Fatal("Need REGION env var")
	case os.Getenv("ACCOUNT"):
		log.Fatal("Need ACCOUNT env var")
	case os.Getenv("KMS"):
		log.Fatal("Need KMS env var")
	case os.Getenv("APPLICATION"):
		log.Fatal("Need APPLICATION env var")
	}

	Headers["Access-Control-Allow-Origin"] = os.Getenv("CORS")
	Region = os.Getenv("REGION")
	KmsKeyId = os.Getenv("KMS")
	AwsAccount = os.Getenv("ACCOUNT")
	AwsSession = session.Must(session.NewSession(&aws.Config{Region: aws.String(Region)}))
	KMS = kms.New(AwsSession)
}

