package sharedpw

import (
	"encoding/base64"
	"encoding/hex"
	"errors"
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/kms"
)

// GetRandomId returns a 8 byte hex-encoded string that is used for the secret ID.
// This function uses AWS KMS to generate the random value.
func GetRandomId() (string, error) {
	result, err := KMS.GenerateRandom(
		&kms.GenerateRandomInput{
			NumberOfBytes: aws.Int64(8),
		},
	)
	if err != nil {
		return "", err
	}
	return hex.EncodeToString(result.Plaintext), nil
}

// EncryptSecret returns a base64 encrypted string given a base64 plaintext input.
// It enforces a max length of 1024 bytes on the input (after decoding from base64)
func EncryptSecret(b64PlainText string) (string, error) {
	decoded, err := base64.StdEncoding.DecodeString(b64PlainText)
	switch {
	case err != nil:
		return "", err
	case len(decoded) < 1:
		return "", errors.New(`plaintext to encrypt too short`)
	case len(decoded) > 2048:
		return "", errors.New(`plaintext to encrypt is too long`)
	}
	out, err := KMS.Encrypt(&kms.EncryptInput{
		EncryptionContext: map[string]*string{
			`account`:     aws.String(AwsAccount),
			`application`: aws.String(Application),
		},
		KeyId:     aws.String(fmt.Sprintf("arn:aws:kms:%s:%s:key/%s", Region, AwsAccount, KmsKeyId)),
		Plaintext: decoded,
	})
	if err != nil {
		return "", err
	}
	return base64.StdEncoding.EncodeToString(out.CiphertextBlob), nil
}

// DecryptSecret returns a bas64 encoded string of the plaintext from an encrypted base64 string using the KMS key
// used to encrypt it.
func DecryptSecret(b64PlainText string) (string, error) {
	decoded, err := base64.StdEncoding.DecodeString(b64PlainText)
	if err != nil {
		return "", errors.New("could not decode base64 string")
	}
	out, err := KMS.Decrypt(&kms.DecryptInput{
		CiphertextBlob: decoded,
		EncryptionContext: map[string]*string{
			`account`:     aws.String(AwsAccount),
			`application`: aws.String(Application),
		},
	})
	if err != nil {
		return "", err
	}
	return base64.StdEncoding.EncodeToString(out.Plaintext), nil
}
