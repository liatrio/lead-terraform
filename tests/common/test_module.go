package common

import (
	"fmt"
	// "io/ioutil"
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

const KubeConfigPath = "kube_config_path"

// TestModule structure for module to test
type TestModule struct {
	GoTest *testing.T
	Name string
	TerraformDir string
	Setup testCallback
	Tests testCallback
	Teardown testCallback
	terraformOptions *terraform.Options
}

type testCallback func(*TestModule) 

func (tm *TestModule) SetString(name string, value string) {
	path := tm.getDataPath()
	test_structure.SaveString(tm.GoTest, path, name, value)
}

func (tm *TestModule) GetString(name string) string {
	path := tm.getDataPath()
	return test_structure.LoadString(tm.GoTest, path, name)
}

func (t *TestModule) SetStringGlobal(name string, value string) {
	path, err := os.Getwd()
	if err != nil {
		t.GoTest.Fatalf("Failed setting global string '%s'. Could not get working directory: %s", name, err)
	}
	test_structure.SaveString(t.GoTest, path, name, value)
}

func (t *TestModule) GetStringGlobal(name string) string {
	path, err := os.Getwd()
	if err != nil {
		t.GoTest.Fatalf("Failed getting global string '%s'. Could not get working directory: %s", name, err)
	}
	return test_structure.LoadString(t.GoTest, path, name)
}

func (tm *TestModule) SetTerraformVar(name string, value string) {
	tm.terraformOptions.Vars[name] = value
}

func (tm *TestModule) GetTerraformVar(name string) string {
	return tm.terraformOptions.Vars[name].(string)
}

func (t *TestModule) SetTerraformOptions(terraformOptions *terraform.Options) {
	path := t.getDataPath()
	test_structure.SaveTerraformOptions(t.GoTest, path, terraformOptions)
}

func (t *TestModule) GetTerraformOptions() *terraform.Options {
	path := t.getDataPath()
	return test_structure.LoadTerraformOptions(t.GoTest, path)
}

func (t *TestModule) GetTerraformOutput(name string) string {
	return terraform.Output(t.GoTest, t.terraformOptions, name)
}

func (tm *TestModule) RunTests() {
	path := tm.getDataPath()

	if  test_structure.IsTestDataPresent(tm.GoTest, test_structure.FormatTestDataPath(path, "TerraformOptions.json")) {
		tm.terraformOptions = tm.GetTerraformOptions()
	} else {
		tm.terraformOptions = &terraform.Options{
			TerraformDir: tm.TerraformDir,
			Vars: map[string]interface{}{},
			NoColor: true,
		}
	}

	stage := fmt.Sprintf("%s_%s", tm.Name, "run")
	test_structure.RunTestStage(tm.GoTest, stage, func() {
		if tm.Setup != nil {
			tm.Setup(tm)
		}
		tm.SetTerraformOptions(tm.terraformOptions)
		terraform.InitAndApply(tm.GoTest, tm.terraformOptions)
		if tm.Tests != nil {
			tm.Tests(tm)
		}
	})
}

func (tm *TestModule) TeardownTests() {
	path := tm.getDataPath()
	stage := fmt.Sprintf("%s_%s", tm.Name, "teardown")
	test_structure.RunTestStage(tm.GoTest, stage, func() {
		terraformOptions := tm.GetTerraformOptions()
		terraform.Destroy(tm.GoTest, terraformOptions)
		if tm.Teardown != nil {
			tm.Teardown(tm)
		}
		test_structure.CleanupTestDataFolder(tm.GoTest, path)
	})
}

func (tm *TestModule) getDataPath() string {
	return tm.TerraformDir
}