resource "random_string" "artifactory_xray_db_password" {
  length  = 10
  special = false
 }
 resource "random_string" "artifactory_xray_mongo_db_password" {
   length  = 10
   special = false
}

//  data "helm_repository" "jfrog" {
//   name = "jfrog"
//   url  = "https://charts.jfrog.io"
// }

resource "helm_release" "xray" {
  repository = "${data.helm_repository.jfrog.metadata.0.name}"
  name       = "xray"
  namespace  = "${module.toolchain_namespace.name}"
  chart      = "xray"
  version    = "0.12.10"
  timeout    = 1200

  // set_sensitive {
  //   name  = "xray.license.licenseKey"
  //   value = "${var.artifactory_xray_license}"
  // }

  set_sensitive {
     name  = "mongodb.mongodbPassword"
     value = "${random_string.artifactory_xray_mongo_db_password.result}"
   }

  set_sensitive {
     name  = "postgresql.postgresPassword"
     value = "${random_string.artifactory_xray_db_password.result}"
   }

}
