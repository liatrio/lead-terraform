package common

import (
	"fmt"
	"os"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/iam"
	"github.com/aws/aws-sdk-go/service/sqs"
  "github.com/aws/aws-sdk-go/service/sts"
  "github.com/aws/aws-sdk-go/service/codepipeline"


	terratestAws "github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
)

func CodeServicesTest(t *testing.T) {
  t.Parallel()

  assumeIamRole, _ := os.LookupEnv("TERRATEST_IAM_ROLE")

  testCodeServices := TestModule{
    GoTest: t,
    Name: "codeServices",
    TerraformDir: "../testdata/aws/code-services",
    Setup: func (tm *TestModule) {
      tm.SetTerraformVar("cluster", tm.GetStringGlobal("clusterName"))
      tm.SetTerraformVar("region", "us-east-1")
      tm.SetTerraformVar("aws_assume_role_arn", assumeIamRole)
      tm.SetTerraformVar("toolchain_namespace", tm.GetStringGlobal("namespace"))
      tm.SetTerraformVar("openid_connect_provider_arn", tm.GetStringGlobal("aws_iam_openid_connect_provider_arn"))
      tm.SetTerraformVar("openid_connect_provider_url", tm.GetStringGlobal("aws_iam_openid_connect_provider_url"))
    },
    Tests: func (tm *TestModule) {
      // Setup Test
      var (
        sqsURL string
        expectedMessage string
        timeout int64
      )

      sqsURL = tm.GetTerraformOutput("sqs_url")
      expectedMessage = random.UniqueId()
      timeout = 5

      err := terratestAws.SendMessageToQueueE(tm.GoTest, "us-east-1", sqsURL, expectedMessage)
      if err != nil {
        tm.GoTest.Fatal("couldn't send message to SQS queue")
        return
      }

      awsAdminSession, err := terratestAws.NewAuthenticatedSession("us-east-1")
      if err != nil {
        tm.GoTest.Fatal("couldn't create aws authenticated session", err)
        return
      }

			iamClient := iam.New(awsAdminSession)
			stsClient := sts.New(awsAdminSession)
      
      callerIdentity, err := stsClient.GetCallerIdentity(&sts.GetCallerIdentityInput{})
			if err != nil {
				tm.GoTest.Fatalf("Failed fetching AWS caller identity")
			}

      assumeRolePolicy := fmt.Sprintf("{\"Version\": \"2012-10-17\",\"Statement\": [{\"Effect\": \"Allow\",\"Principal\": {\"AWS\": \"%s\"},\"Action\": \"sts:AssumeRole\"}]}", *callerIdentity.Arn)
      roleName := fmt.Sprintf("%s-testing-role", tm.GetStringGlobal("clusterName"))
      defer iamClient.DeleteRole(&iam.DeleteRoleInput{RoleName: &roleName})
      roleResponse, err := iamClient.CreateRole(&iam.CreateRoleInput{
        AssumeRolePolicyDocument: &assumeRolePolicy,
        RoleName:                 &roleName,
      })
      if err != nil {
        tm.GoTest.Fatal("couldn't create an aws role", err)
        return
      }

      eventMapperPolicyArn := tm.GetTerraformOutput("event_mapper_role_policy_arn")

      defer iamClient.DetachRolePolicy(&iam.DetachRolePolicyInput{
          PolicyArn: &eventMapperPolicyArn,
          RoleName:  roleResponse.Role.RoleName,
			})
			_, err = iamClient.AttachRolePolicy(&iam.AttachRolePolicyInput{
        PolicyArn: &eventMapperPolicyArn,
        RoleName:  roleResponse.Role.RoleName,
      })
      if err != nil {
        tm.GoTest.Fatal("couldn't attach policy to role", err)
        return
      }

      eventMapperSession, err := assumeRole(*roleResponse.Role.Arn)
      if err != nil {
        tm.GoTest.Fatal(err)
      }

      // Assert reading codepipeline execution using event mapper policy works(does not return AccessDeniedException)
      codePipelineClient := codepipeline.New(eventMapperSession)
      _, err = codePipelineClient.GetPipelineExecution(&codepipeline.GetPipelineExecutionInput{
        PipelineExecutionId: aws.String("11111111-1111-1111-1111-111111111111"),
        PipelineName: aws.String(random.UniqueId()),
      })
      assert.Error(tm.GoTest, err)
      assert.Equal(tm.GoTest, "PipelineNotFoundException", err.(awserr.Error).Code())

      // Assert adding message to queue using event mapper policy fails
      sqsClient := sqs.New(eventMapperSession)
      _, err = sqsClient.SendMessage(&sqs.SendMessageInput{
        MessageBody: aws.String(random.UniqueId()),
        QueueUrl: &sqsURL,
      })
      assert.Error(tm.GoTest, err)

      // Assert reading message from queue using event mapper policy works
      output, err := sqsClient.ReceiveMessage(&sqs.ReceiveMessageInput{
        QueueUrl: &sqsURL,
        WaitTimeSeconds: &timeout,
      })
      assert.NoError(tm.GoTest, err)
      assert.Len(tm.GoTest, output.Messages, 1)
      assert.Equal(tm.GoTest, expectedMessage, *output.Messages[0].Body)

      // Assert deleteing message from queue using event mapper policy works
      _, err = sqsClient.DeleteMessage(&sqs.DeleteMessageInput{
        ReceiptHandle: output.Messages[0].ReceiptHandle,
        QueueUrl: &sqsURL,
      })
      assert.NoError(tm.GoTest, err)
    },
  }
  defer testCodeServices.TeardownTests()
  testCodeServices.RunTests()
}

func assumeRole(role string) (session *session.Session, err error) {
  session, err = terratestAws.CreateAwsSessionFromRole("us-east-1", role)
  stsClient := sts.New(session)
  for timeout := 60; timeout > 0; timeout-- {
    _, err = stsClient.GetCallerIdentity(&sts.GetCallerIdentityInput{})
    if err == nil {
      return session, nil
    }
    time.Sleep(1 * time.Second)
  }
  return nil, fmt.Errorf("Failed to assume event mapper policy role: %s", err)
}