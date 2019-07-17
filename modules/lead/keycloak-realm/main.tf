# while using client credentials is preferred, it would require initial client creation using the 
# old realm import method, so just use password based setup since that is known prior to keycloak 
# resource creation
provider "keycloak" {
  client_id = "admin-cli"
  username  = var.username
  password  = var.password
  url       = "https://${var.domain}"
}