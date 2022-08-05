package test

import (
	"fmt"
	"net/http"
	"os"
	"path"
	"testing"
	"time"

	"github.com/google/go-containerregistry/pkg/authn"
	"github.com/google/go-containerregistry/pkg/name"
	"github.com/google/go-containerregistry/pkg/v1/remote"
	"github.com/gruntwork-io/go-commons/random"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/liatrio/lead-terraform/test/common"
	"github.com/stretchr/testify/assert"
)

func TestHarbor_Basic(t *testing.T) {
	t.Parallel()

	namespace := common.CreateNamespace(t)
	adminPassword, err := random.RandomString(16, random.Base62Chars)
	dbPassword, err := random.RandomString(16, random.Base62Chars)
	if err != nil {
		t.Fatal(err)
	}

	defer common.Cleanup(t, nil)

	common.RunTerraform(t, path.Join(".", "fixtures", "basic"), func(k8sOpts *k8s.KubectlOptions) map[string]interface{} {
		return map[string]interface{}{
			"namespace":       namespace,
			"harbor_hostname": fmt.Sprintf("%s.apps.vcluster.lead.%s.liatr.io", namespace, os.Getenv("CURRENT_ACCOUNT")),
			"kubeconfig_path": k8sOpts.ConfigPath,
			"admin_password":  adminPassword,
			"db_password":     dbPassword,
		}
	})

	common.RunTestStage(t, "verify image push", func(k8sOpts *k8s.KubectlOptions, terraformOpts *terraform.Options) {
		harborHost := terraform.Output(t, terraformOpts, "harbor_hostname")

		var harborHealthErr error
		for i := 0; i < 10; i++ {
			response, harborHealthErr := http.Get(fmt.Sprintf("https://%s", harborHost))
			if harborHealthErr != nil {
				t.Log("harbor isn't ready yet, waiting 15 seconds...")
				time.Sleep(15 * time.Second)
				continue
			}

			assert.Equal(t, http.StatusOK, response.StatusCode)
			t.Log("harbor is ready, continuing with test")
			break
		}
		assert.NoError(t, harborHealthErr)

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
		assert.NoError(t, err)
	})
}
