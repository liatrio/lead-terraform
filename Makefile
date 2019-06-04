COMMAND ?= "apply"

validate:
	@terraform init -backend=false stacks/environment-aws
	@terraform validate -check-variables=false stacks/environment-aws

%: environments/%
	cd $< && terragrunt $(COMMAND) 

clean:
	@find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;
	@find . -type d -name ".terraform" -prune -exec rm -rf {} \;

kubeconfig-aws:
	@aws-vault exec $(AWS_PROFILE) -- aws eks update-kubeconfig --name lead