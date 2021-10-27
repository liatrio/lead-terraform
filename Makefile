PLANS := $(wildcard stages/cloud-provider/*/*) $(wildcard stages/apps/*) $(wildcard stages/config/*) $(wildcard stacks/*)

.PHONY: validate clean test test-aws test-aws-nodestroy package-kube-downscaler $(PLANS)

init validate clean: $(PLANS)
$(PLANS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

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
