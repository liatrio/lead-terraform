brew 'terraform'
brew 'terragrunt'
brew 'kubernetes-cli'
brew 'kubernetes-helm'
brew 'aws-iam-authenticator'
brew 'azure-cli'
brew 'dnsmasq'
brew 'go'

# If using Linuxbrew, install brew formula, otherwise use the macOS cask
if `uname -s`.strip.eql?('Linux')
  brew 'aws-vault'
else
  tap 'homebrew/cask'
  cask 'aws-vault'
end
