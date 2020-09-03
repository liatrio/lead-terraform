package main

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/sts"
)

func main() {
	sess, err := session.NewSession(nil)
	if err != nil {
		panic(err)
	}

	stsService := sts.New(sess)

	stsRequest, _ := stsService.GetCallerIdentityRequest(&sts.GetCallerIdentityInput{})
	stsRequest.Sign()

	headers, err := json.Marshal(stsRequest.HTTPRequest.Header)
	if err != nil {
		panic(err)
	}

	fmt.Print(base64.StdEncoding.EncodeToString(headers))
}
