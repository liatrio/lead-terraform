affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: "kubernetes.io/lifecycle"
          operator: "NotIn" 
          values:
          - spot
tolerations:
- key: "${ondemand_toleration_key}"
  operator: "Exists"