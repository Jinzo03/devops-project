output "ecr_repository_url" {
  description = "Target registry URL for Docker pushes"
  value       = aws_ecr_repository.app.repository_url
}

output "vpc_id" {
  description = "Provisioned AWS VPC ID"
  value       = aws_vpc.main.id
}