output "ecr_repository_url" {
  description = "Target registry URL for Docker pushes"
  value       = aws_ecr_repository.app.repository_url
}

output "vpc_id" {
  description = "Provisioned AWS VPC ID"
  value       = aws_vpc.main.id
}

output "alb_dns_name" {
  description = "Public URL of Application Load Balancer"
  value       = aws_lb.main.dns_name
}
output "eks_cluster_name" {
  description = "Name of the provisioned EKS Cluster"
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  description = "Kubernetes API server endpoint"
  value       = aws_eks_cluster.main.endpoint
}