package test

import (
	"fmt"
	"os"
	"path"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/files"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	ts "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestCertManager_Basic(t *testing.T) {
	t.Parallel()

	defer ts.RunTestStage(t, "delete_testdata", func() {
		if err := os.RemoveAll(".test-data"); err != nil {
			t.Errorf("error removing test data: %s", err)
		}
	})

	defer ts.RunTestStage(t, "delete_namespace", func() {
		k8sOpts := ts.LoadKubectlOptions(t, ".")
		namespace := ts.LoadString(t, ".", "namespace")
		if namespace != "" {
			k8s.DeleteNamespace(t, k8sOpts, namespace)
		}
	})

	defer ts.RunTestStage(t, "destroy_setup", func() {
		tfDir := ts.LoadString(t, ".", "setup_tfdir")
		terraformOpts := ts.LoadTerraformOptions(t, tfDir)
		terraform.Destroy(t, terraformOpts)
	})

	defer ts.RunTestStage(t, "destroy_cert_manager", func() {
		tfDir := ts.LoadString(t, ".", "tfdir")
		if tfDir == "" {
			return
		}

		tfOpts := ts.LoadTerraformOptions(t, tfDir)
		terraform.Destroy(t, tfOpts)
	})

	ts.RunTestStage(t, "create_namespace", func() {
		namespace := fmt.Sprintf("terratest-%s", strings.ToLower(random.UniqueId()))
		ts.SaveString(t, ".", "namespace", namespace)

		kubectlOptions := k8s.NewKubectlOptions("", "", "")
		ts.SaveKubectlOptions(t, ".", kubectlOptions)
		k8s.CreateNamespace(t, kubectlOptions, namespace)
	})

	ts.RunTestStage(t, "setup", func() {
		namespace := ts.LoadString(t, ".", "namespace")
		tfdir, err := files.CopyTerraformFolderToTemp("../../../environment/aws/iam/cert-manager", "tf-cert-manager-setup-")
		if err != nil {
			t.Errorf("error copying setup module to tmpdir: %s", err)
		}

		ts.SaveString(t, ".", "setup_tfdir", tfdir)
		if err = files.CopyFolderContents(path.Join(".", "fixtures", "setup"), tfdir); err != nil {
			t.Errorf("error copying fixtures to tmpdir: %s", err)
		}

		setupOpts := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
			TerraformDir: tfdir,
			Vars: map[string]interface{}{
				"namespace": namespace,
				"cluster": namespace,
				// TODO: replace with config from vcluster
				"openid_connect_provider_arn": "arn:aws:iam::1234:oidc-provider/idp.example.com",
				"openid_connect_provider_url": "https://idp.example.com",
			},
		})
		ts.SaveTerraformOptions(t, tfdir, setupOpts)
		terraform.InitAndApply(t, setupOpts)

		certManagerServiceAccountArn := terraform.Output(t, setupOpts, "cert_manager_service_account_arn")
		assert.NotEmpty(t, certManagerServiceAccountArn)
		ts.SaveString(t, ".", "cert_manager_service_account_arn", certManagerServiceAccountArn)
	})

	ts.RunTestStage(t, "cert_manager", func() {
		expectedStatus := "deployed"
		tfdir, err := files.CopyTerraformFolderToTemp("../", "tf-cert-manager-")
		if err != nil {
			t.Errorf("error copying module to tmpdir: %s", err)
		}

		ts.SaveString(t, ".", "tfdir", tfdir)
		if err = files.CopyFolderContents(path.Join(".", "fixtures", "basic"), tfdir); err != nil {
			t.Errorf("error copying fixtures to tmpdir: %s", err)
		}

		namespace := ts.LoadString(t, ".", "namespace")
		roleArn := ts.LoadString(t, ".", "cert_manager_service_account_arn")
		terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
			TerraformDir: tfdir,
			Vars: map[string]interface{}{
				"namespace":                             namespace,
				"cert_manager_service_account_role_arn": roleArn,
			},
			NoColor: true,
		})
		ts.SaveTerraformOptions(t, tfdir, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)

		actualNamespace := terraform.Output(t, terraformOptions, "namespace")
		actualStatus := terraform.Output(t, terraformOptions, "status")

		assert.Equal(t, namespace, actualNamespace)
		assert.Equal(t, expectedStatus, actualStatus)
	})

	//ts.RunTestStage(t, "issue_certificate", func() {
	//
	//})
}
