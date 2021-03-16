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
PLANS := $(wildcard stages/cloud-provider/*/*) $(wildcard stages/apps/*) $(wildcard stages/config/*) $(wildcard stacks/*)

.PHONY: validate clean promote test test-aws test-aws-nodestroy package-kube-downscaler $(PLANS)

init validate clean: $(PLANS)
$(PLANS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

cleanz:
	@find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;
	@find . -type d -name ".terraform" -prune -exec rm -rf {} \;
	@find . -type d -name ".test-data" -prune -exec rm -rf {} \;
	@find . -type f -name "terraform.tfstate" -prune -exec rm {} \;
	@find . -type f -name "terraform.tfstate.backup" -prune -exec rm {} \;

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

package-kube-downscaler:
	git clone https://github.com/hjacobs/kube-downscaler.git /tmp/kube-downscaler/
	helm package /tmp/kube-downscaler/helm-chart -d /tmp/kube-downscaler/
	helm s3 push /tmp/kube-downscaler/kube-downscaler-*.tgz liatrio-s3 --acl "public-read" --force
	rm -rf /tmp/kube-downscaler
