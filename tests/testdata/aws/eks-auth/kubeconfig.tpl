apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: ${certificate-authority-data}
    server: ${server}
  name: ${cluster_name}
contexts:
- context:
    cluster: ${cluster_name}
    user: ${cluster_name}
  name: ${cluster_name}
current-context: ${cluster_name}
preferences: {}
users:
- name: ${cluster_name}
  user:
    token: ${token}