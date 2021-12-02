package test

import (
	"fmt"
	"github.com/google/go-containerregistry/pkg/authn"
	"github.com/google/go-containerregistry/pkg/name"
	"github.com/google/go-containerregistry/pkg/v1/remote"
	"github.com/gruntwork-io/go-commons/random"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/liatrio/lead-terraform/test/common"
	"path"
	"testing"
)

func TestHarbor_Basic(t *testing.T) {
	t.Parallel()

	namespace := common.CreateNamespace(t)
	adminPassword, err := random.RandomString(16, random.Base62Chars)
	if err != nil {
		t.Fatal(err)
	}

	defer common.Cleanup(t, nil)

	common.RunTerraform(t, path.Join(".", "fixtures", "basic"), func(k8sOpts *k8s.KubectlOptions) map[string]interface{} {
		return map[string]interface{}{
			"namespace":       namespace,
			"kubeconfig_path": k8sOpts.ConfigPath,
			"admin_password":  adminPassword,
		}
	})

	common.RunTestStage(t, "verify image push", func(k8sOpts *k8s.KubectlOptions, terraformOpts *terraform.Options) {
		harborHost := terraform.Output(t, terraformOpts, "harbor_hostname")

		image, err := remote.Image(name.MustParseReference("docker.io/alpine:latest"))
		if err != nil {
			t.Fatal(err)
		}

		newImageRef, err := name.ParseReference(fmt.Sprintf("%s/library/alpine:latest", harborHost))
		if err != nil {
			t.Fatal(err)
		}

		err = remote.Write(newImageRef, image, remote.WithAuth(&authn.Basic{
			Username: "admin",
			Password: adminPassword,
		}))
		if err != nil {
			t.Fatal(err)
		}
	})
}
