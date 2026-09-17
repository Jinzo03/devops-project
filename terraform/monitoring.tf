resource "helm_release" "prometheus_stack" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true

  values = [
    <<-EOT
    grafana:
      adminPassword: "admin-password-change-me"
      service:
        type: ClusterIP

    alertmanager:
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
    EOT
  ]

  depends_on = [aws_eks_node_group.main]
}