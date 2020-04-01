package aws

import (
    "flag"
    "fmt"

    "os"
    "strings"

    "liatr.io/lead-terraform/tests/common"

    "github.com/aws/aws-sdk-go/service/iam"
    "github.com/aws/aws-sdk-go/service/sqs"
    terratestAws "github.com/gruntwork-io/terratest/modules/aws"
    "github.com/gruntwork-io/terratest/modules/random"
    "github.com/stretchr/testify/assert"
    "testing"
)

const Cluster = "clusterName"
const Namespace = "namespace"

var flagNoColor bool

func init()  {
  flag.BoolVar(&flagNoColor, "noColor", false, "Disable color in log output")
}

func TestSetupEks(t *testing.T) {
  assumeIamRole, _ := os.LookupEnv("TERRATEST_IAM_ROLE")
  var clusterName string
  // CLUSTER
  testCluster := common.TestModule{
    GoTest: t,
    Name: "eks_cluster",
    TerraformDir: "../testdata/aws/eks",
    Setup: func(tm *common.TestModule) {
      if clusterNameEnv, ok := os.LookupEnv("CLUSTER"); ok {
        clusterName = clusterNameEnv
      } else {
        clusterName = fmt.Sprintf("test-%s", strings.ToLower(random.UniqueId()))
      }
      tm.SetTerraformVar("cluster", clusterName)
      tm.SetTerraformVar("region", "us-east-1")
      tm.SetTerraformVar("aws_assume_role_arn", assumeIamRole)
    },
    Tests: func(tm *common.TestModule) {
      tm.SetStringGlobal(Cluster, tm.GetTerraformVar("cluster"))
      tm.SetStringGlobal(common.KubeConfigPath, tm.GetTerraformOutput("kubeconfig"))
      awsIamOpenidConnectProvider := tm.GetTerraformOutputMap("aws_iam_openid_connect_provider")
      tm.SetStringGlobal("aws_iam_openid_connect_provider_arn", awsIamOpenidConnectProvider["arn"])
      tm.SetStringGlobal("aws_iam_openid_connect_provider_url", awsIamOpenidConnectProvider["url"])
    },
  }
  defer testCluster.TeardownTests()
  testCluster.RunTests()

  // NAMESPACE
  testNamespace := common.TestModule{
    GoTest: t,
    Name: "namespace",
    TerraformDir: "../testdata/common/namespace",
    Setup: func(tm *common.TestModule) {
      tm.SetTerraformVar("kube_config_path", testCluster.GetTerraformOutput("kubeconfig"))
      common.NamespaceSetup(tm)
    },
    Tests: func(tm *common.TestModule) {
      common.NamespaceTests(tm)
      tm.SetStringGlobal("namespace", tm.GetTerraformVar("namespace"))
    },
  }
  defer testNamespace.TeardownTests()
  testNamespace.RunTests()

  // CERT-MANAGER
  testCertManager := common.TestModule{
    GoTest: t,
    Name: "cert_manager",
    TerraformDir: "../testdata/tools/cert-manager",
    Setup: func(tm *common.TestModule) {
      tm.SetTerraformVar("namespace", testNamespace.GetTerraformVar("namespace"))
      tm.SetTerraformVar("kube_config_path", testCluster.GetTerraformOutput("kubeconfig"))
    },
    Tests: common.CreateCertManager,
    Teardown: common.DestroyCertManager,
  }
  defer testCertManager.TeardownTests()
  testCertManager.RunTests()

  // TEST CREATE SELF SIGNED ISSUER
  testIssuer := common.TestModule{
    GoTest: t,
    Name: "issuer",
    TerraformDir: "../testdata/common/cert-issuer",
    Setup: func(tm *common.TestModule)  {
      tm.SetTerraformVar("kube_config_path", testCluster.GetTerraformOutput("kubeconfig"))
      tm.SetTerraformVar("namespace", testNamespace.GetTerraformVar("namespace"))
      tm.SetTerraformVar("issuer_kind", "Issuer")
      tm.SetTerraformVar("issuer_name", "test-issuer")
      tm.SetTerraformVar("issuer_type", "selfSigned")
    },
  }
  defer testIssuer.TeardownTests()
  testIssuer.RunTests()

  // Ingress Controller
  testIngressController := common.TestModule{
    GoTest: t,
    Name: "ingress",
    TerraformDir: "../testdata/lead/toolchain-ingress",
    Setup: func(tm *common.TestModule) {
      tm.SetTerraformVar("kube_config_path", testCluster.GetTerraformOutput("kubeconfig"))
      tm.SetTerraformVar("namespace", testNamespace.GetTerraformVar("namespace"))
      tm.SetTerraformVar("cluster_domain", "tests.lead-terraform.liatr.io")
      tm.SetTerraformVar("issuer_kind", "ClusterIssuer")
      tm.SetTerraformVar("issuer_name", "test-issuer")
      tm.SetTerraformVar("crd_waiter", "NA")
    },
  }
  defer testIngressController.TeardownTests()
  testIngressController.RunTests()

  t.Run("Modules", testModules)
}

// This runs sub tests in parallel while blocking main tests from being torn down
func testModules(t *testing.T) {
  t.Run("SDM", testLeadSdm)
  t.Run("Dashboard", testLeadDashboard)
  t.Run("CodeServices", testCodeServices)
  t.Run("KubeResourceReport", common.KubeResourceReportTest)
}

func testLeadSdm(t *testing.T) {
  t.Parallel()

  // SDM
  testSdm := common.TestModule{
    GoTest: t,
    Name: "sdm",
    TerraformDir: "../testdata/tools/sdm",
    Setup: func(tm *common.TestModule) {
      tm.SetTerraformVar("kube_config_path", tm.GetStringGlobal(common.KubeConfigPath))

      tm.SetTerraformVar("product_stack", "aws")
      tm.SetTerraformVar("namespace", tm.GetStringGlobal(Namespace))
      tm.SetTerraformVar("system_namespace", tm.GetStringGlobal(Namespace))
      tm.SetTerraformVar("sdm_version", common.LeadSdmVersion)
      tm.SetTerraformVar("product_version", "2.0.0")
      tm.SetTerraformVar("cluster_id", tm.GetStringGlobal(Cluster))
      tm.SetTerraformVar("slack_bot_token", "xoxb-1111111111-111111111111-aaaaaaaaaaaaaaaaaaaaaaaa")
      tm.SetTerraformVar("slack_client_signing_secret", "11111111111111111111111111111111")
      tm.SetTerraformVar("root_zone_name", "lead-terraform.test.liatr.io")
    },
  }
  defer testSdm.TeardownTests()
  testSdm.RunTests()
}

func testLeadDashboard(t *testing.T) {
  t.Parallel()

  // LEAD Dashboard
  testLeadDashboard := common.TestModule{
    GoTest: t,
    Name: "dashboard",
    TerraformDir: "../testdata/lead/dashboard",
    Setup: func (tm *common.TestModule)  {
      tm.SetTerraformVar("kube_config_path", tm.GetStringGlobal(common.KubeConfigPath))
      tm.SetTerraformVar("namespace", tm.GetStringGlobal(Namespace))
      tm.SetTerraformVar("root_zone_name", "lead-terraform.test.liatr.io")
      tm.SetTerraformVar("cluster_id", tm.GetStringGlobal(Cluster))
      tm.SetTerraformVar("cluster_domain", "lead-terraform.test.liatr.io")
      tm.SetTerraformVar("dashboard_version", common.DashboardVersion)
    },
  }
  defer testLeadDashboard.TeardownTests()
  testLeadDashboard.RunTests()
}

func testCodeServices(t *testing.T) {
  t.Parallel()

  assumeIamRole, _ := os.LookupEnv("TERRATEST_IAM_ROLE")

  testCodeServices := common.TestModule{
    GoTest: t,
    Name: "codeServices",
    TerraformDir: "../testdata/aws/code-services",
    Setup: func (tm *common.TestModule) {
      tm.SetTerraformVar("cluster", tm.GetStringGlobal(Cluster))
      tm.SetTerraformVar("region", "us-east-1")
      tm.SetTerraformVar("aws_assume_role_arn", assumeIamRole)
      tm.SetTerraformVar("toolchain_namespace", tm.GetStringGlobal(Namespace))
      tm.SetTerraformVar("openid_connect_provider_arn", tm.GetStringGlobal("aws_iam_openid_connect_provider_arn"))
      tm.SetTerraformVar("openid_connect_provider_url", tm.GetStringGlobal("aws_iam_openid_connect_provider_url"))
    },
    Tests: func (tm *common.TestModule) {
      var (
        sqsUrl string
        expectedMessage string
        timeout int64
      )

      sqsUrl = tm.GetTerraformOutput("sqs_url")
      expectedMessage = random.UniqueId()
      timeout = 5

      err := terratestAws.SendMessageToQueueE(tm.GoTest, "us-east-1", sqsUrl, expectedMessage)
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

      awsAccountId, err := terratestAws.GetAccountIdE(tm.GoTest)
      if err != nil {
        tm.GoTest.Fatal("couldn't get sts CallerIdentity", err)
        return
      }

      policy := fmt.Sprintf("{\"Version\": \"2012-10-17\",\"Statement\": [{\"Effect\": \"Allow\",\"Principal\": {\"AWS\": \"arn:aws:iam::%s:role/Administrator\"},\"Action\": \"sts:AssumeRole\"}]}", awsAccountId)
      roleName := fmt.Sprintf("%s-testing-role", tm.GetStringGlobal(Cluster))
      defer iamClient.DeleteRole(&iam.DeleteRoleInput{RoleName: &roleName})
      roleResponse, err := iamClient.CreateRole(&iam.CreateRoleInput{
        AssumeRolePolicyDocument: &policy,
        RoleName:                 &roleName,
      })
      if err != nil {
        tm.GoTest.Fatal("couldn't create an aws role", err)
        return
      }

      policyArn := tm.GetTerraformOutput("event_mapper_role_policy_arn")

      defer iamClient.DetachRolePolicy(&iam.DetachRolePolicyInput{
          PolicyArn: &policyArn,
          RoleName:  roleResponse.Role.RoleName,
      })
      _, err = iamClient.AttachRolePolicy(&iam.AttachRolePolicyInput{
        PolicyArn: &policyArn,
        RoleName:  roleResponse.Role.RoleName,
      })
      if err != nil {
        tm.GoTest.Fatal("couldn't attach policy to role", err)
        return
      }

      eventMapperSession := terratestAws.AssumeRole(awsAdminSession, *roleResponse.Role.Arn)
      /*eventMapperSession, err := terratestAws.CreateAwsSessionFromRole("us-east-1", *roleResponse.Role.Arn)
      if err != nil {
        tm.GoTest.Fatal("couldn't send message to SQS queue", err)
        return
      }*/
      svc := sqs.New(eventMapperSession)

      tempMessage := random.UniqueId()

      _, err = svc.SendMessage(&sqs.SendMessageInput{
        MessageBody: &tempMessage,
        QueueUrl: &sqsUrl,
      })
      assert.Error(tm.GoTest, err)

      output, err := svc.ReceiveMessage(&sqs.ReceiveMessageInput{
        QueueUrl: &sqsUrl,
        WaitTimeSeconds: &timeout,
      })
      assert.NoError(tm.GoTest, err)

      tm.GoTest.Log("printing message output")
      tm.GoTest.Log(output.String())

      assert.Len(tm.GoTest, output.Messages, 1)
      message := output.Messages[0].Body
      messageReceipt := output.Messages[0].ReceiptHandle

      assert.Equal(tm.GoTest, expectedMessage, *message)

      _, err = svc.DeleteMessage(&sqs.DeleteMessageInput{
        ReceiptHandle: messageReceipt,
        QueueUrl: &sqsUrl,
      })
      assert.NoError(tm.GoTest, err)
    },
  }
  defer testCodeServices.TeardownTests()
  testCodeServices.RunTests()
}
