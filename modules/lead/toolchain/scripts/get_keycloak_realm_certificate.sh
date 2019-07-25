#!/bin/sh
# this script will download a Keycloak realm SAML desriptor and parse out the realm's signing certifcate into a JSON response
curl -s $1 | tr -d "\n" | awk -F"dsig:X509Certificate>|</dsig:X509Certificate" '{print "{\"certifcate\":\"" $2 "\"}"'}