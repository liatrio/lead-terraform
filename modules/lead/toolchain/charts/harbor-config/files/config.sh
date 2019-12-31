#!/bin/sh

set -e

apk add jq curl

basicAuth=$(printf "${HARBOR_USERNAME}:${HARBOR_PASSWORD}" | base64)

function put() {
	curl --fail -k \
		-X PUT \
		-H "Authorization: Basic ${basicAuth}" \
		-H "Content-Type: application/json" \
		-d "${2}" \
		"https://${HARBOR_HOSTNAME}/api${1}"
}

configureOidcPayload=$(jq -n "{
	auth_mode: \"oidc_auth\",
	oidc_client_id: \"harbor\",
	oidc_client_secret: \"${KEYCLOAK_CLIENT_SECRET}\",
	oidc_endpoint: \"https://${KEYCLOAK_HOSTNAME}/auth/realms/toolchain\",
	oidc_groups_claim: \"groups\",
	oidc_name: \"keycloak\",
	oidc_scope: \"openid,email,profile\",
	oidc_verify_cert: true
}")

put "/configurations" "${configureOidcPayload}"
