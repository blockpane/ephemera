package main

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/frameloss/ephemera"
	"log"
	"net"
)

type saveResp struct {
	Error string `json:"error"`
	Id    string `json:"id"`
}

func (r saveResp) String() string {
	s, _ := json.Marshal(r)
	return string(s)
}

func handleRequest(ctx context.Context, request events.APIGatewayProxyRequest) (response events.APIGatewayProxyResponse, err error) {
	response.Headers = sharedpw.Headers
	response.StatusCode = 200
	secret := &sharedpw.Secret{}
	err = json.Unmarshal([]byte(request.Body), secret)
	if err != nil {
		response.Body = pErr(`could not unmarshal body`, err)
		response.StatusCode = 400
		return
	}
	if len(secret.Message) < 1 {
		response.Body = pErr(`got empty secret message`, nil)
		response.StatusCode = 400
		return
	}
	if len(secret.Message) >= 4096 {
		response.Body = pErr(`secret too long'`, nil)
		response.StatusCode = 400
		return
	}
	err = secret.NewId()
	if err != nil {
		response.Body = pErr(`could not assign new ID`, err)
		response.StatusCode = 500
		return
	}
	err = secret.SetTimeout()
	if err != nil {
		response.Body = pErr(`could not set timeout`, err)
		response.StatusCode = 500
		return
	}
	cipherText, err := sharedpw.EncryptSecret(base64.StdEncoding.EncodeToString([]byte(secret.Message)))
	if err != nil {
		response.Body = pErr(`could not encrypt secret`, err)
		response.StatusCode = 500
		return
	}
	err = secret.Save(cipherText)
	if err != nil {
		response.Body = pErr(`could not save secret`, err)
		response.StatusCode = 500
		return
	}
	if len(secret.Ip) > 0 {
		if n := net.ParseIP(secret.Ip); n == nil {
			response.Body = pErr(`invalid IP address filter`, err)
			response.StatusCode = 400
			return
		}
	}
	response.Body = saveResp{Id: secret.Secret}.String()
	return
}

func main() {
	lambda.Start(handleRequest)
}

// pErr is a helper that prints the error to console and returns json to be appended to output
func pErr(s string, e error) string {
	log.Println(s)
	log.Println(e)
	return saveResp{
		Error: s,
	}.String()
}

