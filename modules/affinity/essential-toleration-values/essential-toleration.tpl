affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: "node.liatr.io/lifecycle"
          operator: "NotIn"
          values:
          - preemptible
tolerations:
- key: "${essential_taint_key}"
  operator: "Exists"
