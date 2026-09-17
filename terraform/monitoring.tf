resource "helm_release" "prometheus_stack" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true
  timeout          = 1200
  atomic           = true
  cleanup_on_fail  = true
  wait             = true

  values = [
    <<-EOT
    prometheusOperator:
      resources:
        requests:
          cpu: 100m
          memory: 128Mi
        limits:
          cpu: 200m
          memory: 256Mi

    prometheus:
      prometheusSpec:
        resources:
          requests:
            cpu: 100m
            memory: 512Mi
          limits:
            cpu: 500m
            memory: 1Gi

    grafana:
      adminPassword: "admin-password-change-me"
      service:
        type: ClusterIP
      resources:
        requests:
          cpu: 50m
          memory: 128Mi
        limits:
          cpu: 200m
          memory: 256Mi

    alertmanager:
      alertmanagerSpec:
        resources:
          requests:
            cpu: 50m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
      config:
        global:
          resolve_timeout: 5m
        route:
          group_by: ['alertname']
          group_wait: 30s
          group_interval: 5m
          repeat_interval: 12h
          receiver: 'webhook-receiver'
        receivers:
        - name: 'webhook-receiver'
          webhook_configs:
          - url: 'https://discord.com/api/webhooks/YOUR_DISCORD_OR_SLACK_WEBHOOK_URL'
            send_resolved: true

    kube-state-metrics:
      resources:
        requests:
          cpu: 50m
          memory: 64Mi
        limits:
          cpu: 100m
          memory: 128Mi

    prometheus-node-exporter:
      resources:
        requests:
          cpu: 25m
          memory: 32Mi
        limits:
          cpu: 100m
          memory: 64Mi
    EOT
  ]

  depends_on = [aws_eks_node_group.main]
}
