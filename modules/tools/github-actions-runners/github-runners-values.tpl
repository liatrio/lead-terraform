replicaCount: ${controller_replica_count}

authSecret:
  create: false
  name: ${secret_name}

autoscaling:
  enabled: ${runner_autoscaling_enabled}
  minReplicas: ${runner_autoscaling_min_replicas}
  maxReplicas: ${runner_autoscaling_max_replicas}
  targetCPUUtilizationPercentage: ${runner_autoscaling_cpu_util}
  
