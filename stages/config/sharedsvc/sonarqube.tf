resource "sonarqube_webhook" "webhook" {
  name = "collector"
  url  = var.sonarqube_collector_url
}
