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

	defer ts.RunTestStage(t, "destroy_terraform", func() {
		terraformOpts := ts.LoadTerraformOptions(t, ".")
		terraform.Destroy(t, terraformOpts)
	})

	ts.RunTestStage(t, "create_namespace", func() {
		namespace := fmt.Sprintf("terratest-%s", strings.ToLower(random.UniqueId()))
		ts.SaveString(t, ".", "namespace", namespace)

		kubectlOptions := k8s.NewKubectlOptions("", "", "")
		ts.SaveKubectlOptions(t, ".", kubectlOptions)
		k8s.CreateNamespace(t, kubectlOptions, namespace)
	})

	ts.RunTestStage(t, "terraform", func() {
		expectedStatus := "deployed"
		tfdir, err := files.CopyTerraformFolderToTemp(path.Join(".", "fixtures", "basic"), "tf-cert-manager-")
		if err != nil {
			t.Errorf("error copying module to tmpdir: %s", err)
		}

		namespace := ts.LoadString(t, ".", "namespace")
		terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
			TerraformDir: tfdir,
			Vars: map[string]interface{}{
				"namespace": namespace,
				"cluster":   namespace,
				// TODO: use a separate domain for testing
				"hosted_zone_name": "lead.sandbox.liatr.io.",
				// TODO: replace with config from vcluster
				"oidc_provider_arn": "arn:aws:iam::1234:oidc-provider/idp.example.com",
				"oidc_provider_url": "https://idp.example.com",
			},
			NoColor: true,
		})
		ts.SaveTerraformOptions(t, ".", terraformOptions)
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
