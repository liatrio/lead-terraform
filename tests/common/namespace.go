package common

import (
	"fmt"
	"strings"

	"github.com/gruntwork-io/terratest/modules/random"

	"github.com/stretchr/testify/assert"
)

func NamespaceSetup(tm *TestModule) {
	expectedNamespace := fmt.Sprintf("test-%s", strings.ToLower(random.UniqueId()))
	tm.SetTerraformVar("namespace", expectedNamespace)
}

func NamespaceTests(tm *TestModule) {
	expectedNamespace := tm.GetTerraformVar("namespace")

	actualNamespace := tm.GetTerraformOutput("name")

	assert.Equal(tm.GoTest, expectedNamespace, actualNamespace)
}