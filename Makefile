COMMAND ?= "apply"
LATEST_VERSION := $(shell git tag -l --sort=creatordate | grep "^v[0-9]*.[0-9]*.[0-9]*$$" | tail -1 | cut -c 2-)
ifeq "$(shell git tag -l v$(LATEST_VERSION) --points-at HEAD)" "v$(LATEST_VERSION)"
### latest tag points to current commit, this is a release build
VERSION ?= $(LATEST_VERSION)
else
### latest tag points to prior commit, this is a snapshot build
MAJOR_VERSION := $(word 1, $(subst ., ,$(LATEST_VERSION)))
MINOR_VERSION := $(word 2, $(subst ., ,$(LATEST_VERSION)))
PATCH_VERSION := $(word 3, $(subst ., ,$(LATEST_VERSION)))
VERSION ?= $(MAJOR_VERSION).$(MINOR_VERSION).$(shell echo $$(( $(PATCH_VERSION) + 1)) )-develop
endif
IS_SNAPSHOT = $(if $(findstring -, $(VERSION)),true,false)
TAG_VERSION = v$(VERSION)
### check terraform version, since args are different
TF_VERSION := $(shell terraform --version | head -n1)
### custom TF providers
TF_PLATFORM = $(shell go env GOOS)_$(shell go env GOARCH)
TF_KEYCLOAK_VERSION = 1.18.0
TF_HARBOR_VERSION = 0.1.0
IS_TF_11 = $(if $(findstring 0.11, $(TF_VERSION)),true,false)
ifeq (true,$(IS_TF_11))
TF_VALIDATE_ARGS = "-check-variables=false"
else
TF_VALIDATE_ARGS = ""
endif

validate:
	@terraform init -backend=false stacks/environment-aws
	@terraform validate $(TF_VALIDATE_ARGS) stacks/environment-aws
	@terraform init -backend=false stacks/environment-local
	@terraform validate $(TF_VALIDATE_ARGS) stacks/environment-local
	@terraform init -backend=false stacks/product-aws
	@terraform validate $(TF_VALIDATE_ARGS) stacks/product-aws
	@terraform init -backend=false stacks/product-local
	@terraform validate $(TF_VALIDATE_ARGS) stacks/product-local

%: environments/%
	cd $< && terragrunt $(COMMAND)

clean:
	@find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;
	@find . -type d -name ".terraform" -prune -exec rm -rf {} \;
	@find . -type d -name ".test-data" -prune -exec rm -rf {} \;
	@find . -type f -name "terraform.tfstate" -prune -exec rm {} \;
	@find . -type f -name "terraform.tfstate.backup" -prune -exec rm {} \;

kubeconfig-aws:
	@aws-vault exec $(AWS_PROFILE) -- aws eks update-kubeconfig --name lead

promote:
	@echo "VERSION:$(VERSION) IS_SNAPSHOT:$(IS_SNAPSHOT) LATEST_VERSION:$(LATEST_VERSION)"
ifeq (false,$(IS_SNAPSHOT))
	@echo "Unable to promote a non-snapshot"
	@exit 1
endif
ifneq ($(shell git status -s),)
	@echo "Unable to promote a dirty workspace"
	@exit 1
endif
	$(eval NEW_VERSION := $(word 1,$(subst -, , $(TAG_VERSION))))
	git fetch --tags
	git tag -a -m "releasing $(NEW_VERSION)" $(NEW_VERSION)
	git push origin $(NEW_VERSION)

test:
	cd tests && go test liatr.io/lead-terraform/tests/local -timeout 90m -v --count=1 -parallel 3

test-aws:
	cd tests && go test liatr.io/lead-terraform/tests/aws -timeout 90m -v --count=1

test-aws-nodestroy:
	cd tests && go test liatr.io/lead-terraform/tests/aws -timeout 90m -v --count=1 --destroyCluster=false

plugins:
	mkdir -p ~/.terraform.d/plugins
	curl -LsO https://github.com/mrparkers/terraform-provider-keycloak/releases/download/$(TF_KEYCLOAK_VERSION)/terraform-provider-keycloak_v$(TF_KEYCLOAK_VERSION)_$(TF_PLATFORM).zip
	unzip -d terraform-provider-keycloak_v$(TF_KEYCLOAK_VERSION) terraform-provider-keycloak*.zip -x "../LICENSE"
	cp ./terraform-provider-keycloak_v$(TF_KEYCLOAK_VERSION)/terraform-provider-keycloak_v$(TF_KEYCLOAK_VERSION) ~/.terraform.d/plugins/
	rm ./terraform-provider-keycloak_v$(TF_KEYCLOAK_VERSION)_$(TF_PLATFORM).zip
	rm -rf ./terraform-provider-keycloak_v$(TF_KEYCLOAK_VERSION)
	curl -LsO https://github.com/liatrio/terraform-provider-harbor/releases/download/v$(TF_HARBOR_VERSION)/terraform-provider-harbor_$(TF_HARBOR_VERSION)_$(TF_PLATFORM).zip
	unzip -d terraform-provider-harbor_v$(TF_HARBOR_VERSION) terraform-provider-harbor*.zip
	cp ./terraform-provider-harbor_v$(TF_HARBOR_VERSION)/terraform-provider-harbor_v$(TF_HARBOR_VERSION) ~/.terraform.d/plugins/
	rm ./terraform-provider-harbor_$(TF_HARBOR_VERSION)_$(TF_PLATFORM).zip
	rm -rf ./terraform-provider-harbor_v$(TF_HARBOR_VERSION)

package-kube-downscaler:
	git clone https://github.com/hjacobs/kube-downscaler.git /tmp/kube-downscaler/
	helm package /tmp/kube-downscaler/helm-chart -d /tmp/kube-downscaler/
	helm s3 push /tmp/kube-downscaler/kube-downscaler-*.tgz liatrio-s3 --acl "public-read" --force
	rm -rf /tmp/kube-downscaler
