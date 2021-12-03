package common

import (
	"fmt"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	ts "github.com/gruntwork-io/terratest/modules/test-structure"
	"os"
	"path"
	"strings"
	"testing"
)

type CleaupFunc func(t *testing.T, k8sOpts *k8s.KubectlOptions)
type VarsFunc func(k8sOpts *k8s.KubectlOptions) map[string]interface{}
type TestStageFunc func(k8sOpts *k8s.KubectlOptions, terraformOpts *terraform.Options)

func Cleanup(t *testing.T, beforeDestroy CleaupFunc) {
	ts.RunTestStage(t, "cleanup", func() {
		k8sOpts := ts.LoadKubectlOptions(t, getWorkingDirectory(t))

		if beforeDestroy != nil {
			beforeDestroy(t, k8sOpts)
		}

		terraformOpts := ts.LoadTerraformOptions(t, getWorkingDirectory(t))
		terraform.Destroy(t, terraformOpts)

		namespace := ts.LoadString(t, getWorkingDirectory(t), "namespace")
		if namespace != "" {
			k8s.DeleteNamespace(t, k8sOpts, namespace)
		}

		if err := os.RemoveAll(path.Join(getWorkingDirectory(t), ".test-data")); err != nil {
			t.Errorf("error removing test data: %s", err)
		}
	})
}

func CreateNamespace(t *testing.T) string {
	namespace := fmt.Sprintf("test-%s", strings.ToLower(random.UniqueId()))

	ts.RunTestStage(t, "create namespace", func() {
		ts.SaveString(t, getWorkingDirectory(t), "namespace", namespace)

		kubectlOptions := k8s.NewKubectlOptions("", "", namespace)
		configPath, err := kubectlOptions.GetConfigPath(t)
		if err != nil {
			t.Fatal(err)
		}

		kubectlOptions.ConfigPath = configPath

		ts.SaveKubectlOptions(t, getWorkingDirectory(t), kubectlOptions)
		k8s.CreateNamespace(t, kubectlOptions, namespace)
	})

	return namespace
}

func RunTerraform(t *testing.T, path string, vars VarsFunc) {
	kubectlOptions := ts.LoadKubectlOptions(t, getWorkingDirectory(t))

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: path,
		Vars:         vars(kubectlOptions),
		NoColor:      true,
	})

	ts.SaveTerraformOptions(t, getWorkingDirectory(t), terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}

func RunTestStage(t *testing.T, name string, testStage TestStageFunc) {
	ts.RunTestStage(t, name, func() {
		k8sOpts := ts.LoadKubectlOptions(t, getWorkingDirectory(t))
		terraformOpts := ts.LoadTerraformOptions(t, getWorkingDirectory(t))

		testStage(k8sOpts, terraformOpts)
	})
}

func GetRequiredEnvVar(t *testing.T, varName string) string {
	envVar := os.Getenv(varName)
	if envVar == "" {
		t.Fatalf("expected environment variable '%s' to be set, but wasn't", varName)
	}

	return envVar
}

func getWorkingDirectory(t *testing.T) string {
	dir, err := os.Getwd()
	if err != nil {
		t.Fatal(err)
	}

	return dir
}
