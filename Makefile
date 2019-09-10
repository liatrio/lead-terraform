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
IS_TF_11 = $(if $(findstring 0.11, $(TF_VERSION)),true,false)
ifeq (true,$(IS_TF_11))
TF_VALIDATE_ARGS = "-check-variables=false"
else
TF_VALIDATE_ARGS = ""
endif

validate: 
	@export TF_LOG = DEBUG
	@printenv
	@echo 'First init'
	@terraform init -backend=false stacks/environment-aws
	@echo 'First validate'
	@terraform validate $(TF_VALIDATE_ARGS) stacks/environment-aws
	@echo 'second init'
	@terraform init -backend=false stacks/environment-local
	@echo 'second validate'
	@terraform validate $(TF_VALIDATE_ARGS) stacks/environment-local
	@echo 'third init'
	@terraform init -backend=false stacks/product-aws
	@echo 'third validate'
	@terraform validate $(TF_VALIDATE_ARGS) stacks/product-aws

%: environments/%
	cd $< && terragrunt $(COMMAND) 

clean:
	@find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;
	@find . -type d -name ".terraform" -prune -exec rm -rf {} \;

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

# Install the keycloak provider from the community repository
plugins: build_keycloak_provider
build_keycloak_provider:
	mkdir -p ~/.terraform.d/plugins
	curl -LsO https://github.com/mrparkers/terraform-provider-keycloak/archive/master.zip
	unzip master.zip
	cd ./terraform-provider-keycloak-master; GO111MODULE=on go mod download && make build
	cp ./terraform-provider-keycloak-master/terraform-provider-keycloak ~/.terraform.d/plugins/
	rm ./master.zip
	rm -rf ./terraform-provider-keycloak-master/

## WAITING ON NEW TF KEYCLOAK RELEASE
# TF_KEYCLOAK_VERSION = "1.9.0"
# plugins: install_keycloak_provider_darwin install_keycloak_provider_linux
# install_keycloak_provider_linux:
# 	mkdir -p ~/.terraform.d/plugins
# 	wget https://github.com/mrparkers/terraform-provider-keycloak/releases/download/$(TF_KEYCLOAK_VERSION)/terraform-provider-keycloak_v$(TF_KEYCLOAK_VERSION)_linux_amd64.zip
# 	unzip -d terraform-provider-keycloak_v$(TF_KEYCLOAK_VERSION) terraform-provider-keycloak*.zip -x "../LICENSE"
# 	cp ./terraform-provider-keycloak_v$(TF_KEYCLOAK_VERSION)/terraform-provider-keycloak_v$(TF_KEYCLOAK_VERSION) ~/.terraform.d/plugins/
# 	rm ./terraform-provider-keycloak_v$(TF_KEYCLOAK_VERSION)_linux_amd64.zip
# 	rm -rf ./terraform-provider-keycloak_v$(TF_KEYCLOAK_VERSION)

# install_keycloak_provider_darwin:
# 	mkdir -p ~/.terraform.d/plugins
# 	wget https://github.com/mrparkers/terraform-provider-keycloak/releases/download/$(TF_KEYCLOAK_VERSION)/terraform-provider-keycloak_v$(TF_KEYCLOAK_VERSION)_darwin_amd64.zip
# 	unzip -d terraform-provider-keycloak_v$(TF_KEYCLOAK_VERSION) terraform-provider-keycloak*.zip -x "../LICENSE"
# 	cp ./terraform-provider-keycloak_v$(TF_KEYCLOAK_VERSION)/terraform-provider-keycloak_v$(TF_KEYCLOAK_VERSION) ~/.terraform.d/plugins/
# 	rm ./terraform-provider-keycloak_v$(TF_KEYCLOAK_VERSION)_darwin_amd64.zip
# 	rm -rf ./terraform-provider-keycloak_v$(TF_KEYCLOAK_VERSION)
