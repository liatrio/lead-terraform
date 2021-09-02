resource "sonarqube_webhook" "webhook" {
  name = "rode-sonarqube-collector"
  url  = var.sonarqube_collector_url
}
