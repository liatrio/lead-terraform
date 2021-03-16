
.PHONY: init validate clean 

init: .terraform.lock.hcl

validate: init
	# terraform validate $(TF_ARGS)

clean:
	-rm -rf .terraform .terraform.lock.hcl

.terraform.lock.hcl:
	# terraform init -backend=false $(TF_ARGS)
	@echo "FIX ME!!!"
