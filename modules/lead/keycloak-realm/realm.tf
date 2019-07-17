resource "keycloak_realm" "realm" {
  realm         = var.name
  enabled       = true
  display_name  = title(var.name)

  registration_allowed            = true
  registration_email_as_username  = true
  reset_password_allowed          = true
  remember_me                     = true
  verify_email                    = true
  login_with_email_allowed        = true
  duplicate_emails_allowed        = false

  smtp_server {
    host              = "mailhog"
    port              = "1025"
    from              = "keycloak@${var.domain}"
    from_display_name = "Keycloak - ${title(var.name)}"
  }
}
