# Keycloak Password
If the keycloak database password gets out of sync with the appserver, then `kubectl exec` into the postgres pod and run:

```
sed -ibak 's/^\([^#]*\)md5/\1trust/g' /opt/bitnami/postgresql/conf/pg_hba.conf
pg_ctl reload
psql -U keycloak
alter user keycloak with password '....'
sed -ibak 's/^\([^#]*\)trust/\1md5/g' /opt/bitnami/postgresql/conf/pg_hba.conf
pg_ctl reload
```
