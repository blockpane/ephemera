package main

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/frameloss/ephemera"
	"log"
	"net"
)

type secretRequest struct {
	Id       string `json:"id"`
	Retrieve bool   `json:"retrieve"`
}

type errResp struct {
	Error   string `json:"error"`
	Exists  bool   `json:"exists"`
	HasPass bool   `json:"has_pass"`
	Secret  string `json:"secret"`
	Hint    string `json:"hint"`
	Tag     string `json:"tag"`
	Iv      string `json:"iv"`
	PwTag   string `json:"pw_tag"`
	PwIv    string `json:"pw_iv"`
}

func (r errResp) String() string {
	s, _ := json.Marshal(r)
	return string(s)
}

func handleRequest(ctx context.Context, request events.APIGatewayProxyRequest) (response events.APIGatewayProxyResponse, err error) {
	response.Headers = sharedpw.Headers
	response.StatusCode = 200
	req := &secretRequest{}
	err = json.Unmarshal([]byte(request.Body), req)
	if err != nil {
		fmt.Println(request.Body)
		response.Body = pErr(`could not understand request`, err)
		response.StatusCode = 400
		return
	}
	if len(req.Id) != 16 {
		response.Body = pErr(`not found`, nil)
		return
	}
	ip := net.ParseIP(request.RequestContext.Identity.SourceIP)

	// is this a check for if the record exists?
	if !req.Retrieve {
		exists, err := sharedpw.Reveal(req.Id, ip, false)
		if err != nil {
			log.Println(err)
			response.Body = errResp{
				Error: "could not query for secret",
			}.String()
			return response, nil
		}
		if exists.Exists {
			response.Body = errResp{
				Exists: true,
			}.String()
			return response, nil
		}
		response.Body = errResp{
			Exists: false,
		}.String()
		return response, nil
	}

	// Try to return the secret:
	secret, err := sharedpw.Reveal(req.Id, ip, true)
	if err != nil {
		log.Println(err)
		response.Body = errResp{
			Error: "could not query for secret",
		}.String()
		return response, nil
	}
	plaintext, err := sharedpw.DecryptSecret(secret.Secret)
	if err != nil {
		log.Println(err)
		response.Body = errResp{
			Error: "could not decrypt secret from database",
		}.String()
		response.StatusCode = 500
		return response, nil
	}
	p, err := base64.StdEncoding.DecodeString(plaintext)
	response.Body = errResp{
		Exists:  secret.Exists,
		HasPass: secret.HasPass,
		Secret:  string(p),
		Hint:    secret.Hint,
		Tag:     secret.Tag,
		Iv:      secret.Iv,
		PwTag:   secret.PwTag,
		PwIv:    secret.PwIv,
	}.String()
	return
}

func main() {
	lambda.Start(handleRequest)
}

// pErr is a helper that prints the error to console and returns json to be appended to output
func pErr(s string, e error) string {
	log.Println(s)
	log.Println(e)
	return errResp{
		Error:   s,
		Exists:  false,
		HasPass: false,
		Secret:  ``,
	}.String()
}
