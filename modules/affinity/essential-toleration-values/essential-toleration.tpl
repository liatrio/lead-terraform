affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: "node.kubernetes.io/lifecycle"
          operator: "NotIn"
          values:
          - preemptible
tolerations:
- key: "${essential_taint_key}"
  operator: "Exists"
