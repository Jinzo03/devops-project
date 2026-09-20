# DevOps Project — FastAPI on AWS EKS

A complete, production-style GitOps pipeline: a FastAPI microservice is built, tested, scanned, containerized, and deployed to AWS EKS using Terraform for infrastructure, Helm for packaging, Argo CD for continuous delivery, and the kube-prometheus-stack for observability.

## Architecture

```
GitHub Actions (CI) ──▶ Test + Lint + Trivy Scan ──▶ Build & Push to ECR
                                                              │
                                                              ▼
Terraform ──▶ VPC / EKS / ECR / IAM (OIDC) / kube-prometheus-stack
                                                              │
                                                              ▼
                                Argo CD ──▶ syncs Helm chart ──▶ EKS Deployment
                                                              │
                                                              ▼
                                    Prometheus + Grafana + Alertmanager
```

## Key Components

- **Application** (`app/main.py`) — A minimal FastAPI service with `/` and `/health` endpoints, instrumented with `prometheus-fastapi-instrumentator` to expose a `/metrics` endpoint out of the box. Unit tests live in `tests/`.
- **CI/CD Pipeline** (`.github/workflows/deploy.yml`) — On every push/PR to `main`: runs `ruff` lint and `pytest`, runs a Trivy configuration scan, then (on `main` push only) authenticates to AWS via OIDC, builds and pushes the Docker image to ECR, and verifies EKS connectivity.
- **Infrastructure as Code** (`terraform/`) — Provisions the full AWS footprint: a custom VPC with public subnets (`vpc.tf`), an ECR repository (`ecr.tf`), an EKS cluster with a managed node group (`eks.tf`), an optional ECS/Fargate + ALB path (`ecs.tf`), a GitHub Actions OIDC identity provider and least-privilege IAM role (`oidc.tf`), and a Helm-provisioned kube-prometheus-stack for cluster monitoring (`monitoring.tf`).
- **Helm Chart** (`helm/fastapi-app/`) — Packages the FastAPI app as a Kubernetes `Deployment` and `Service`, with a `ServiceMonitor` and `PrometheusRule` (crash-loop, 5xx error rate, and high-memory alerts) for Prometheus Operator integration. `values.yaml` / `values-dev.yaml` separate prod and dev sizing.
- **GitOps Delivery** (`argocd/application-dev.yaml`) — An Argo CD `Application` that tracks this repo's `helm/fastapi-app` path and auto-syncs (with pruning and self-healing) to the `dev` namespace.
- **Container** (`Dockerfile`) — Multi-stage build producing a slim, non-root runtime image.

## Tech Stack

FastAPI · Docker · GitHub Actions · Trivy · Terraform · AWS (EKS, ECR, VPC, IAM/OIDC) · Helm · Argo CD · Prometheus · Grafana

## Getting Started

### Run the app locally

```bash
git clone https://github.com/Jinzo03/devops-project.git
cd devops-project
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Visit `http://localhost:8000` and `http://localhost:8000/health`; metrics are exposed at `http://localhost:8000/metrics`.

### Run tests

```bash
pip install ruff
ruff check .
pytest
```

### Build the container

```bash
docker build -t fastapi-app .
docker run -p 8000:8000 fastapi-app
```

### Provision the AWS infrastructure

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

This creates the VPC, EKS cluster, ECR repository, the GitHub Actions OIDC role, and the monitoring stack. Update `terraform/variables.tf` and the OIDC subject in `oidc.tf` for your own AWS account and GitHub repo.

### Deploy via Argo CD

Once the cluster and Argo CD are available, apply the Application manifest:

```bash
kubectl apply -f argocd/application-dev.yaml
```

Argo CD will then keep the `dev` namespace in sync with `helm/fastapi-app`.

## CI/CD Flow

1. **Test** — lint (`ruff`) and unit tests (`pytest`) on every push/PR.
2. **Security scan** — Trivy configuration scan against IaC and manifests.
3. **Build & push** — on `main`, the image is built and pushed to ECR, tagged with the commit SHA and `latest`, using short-lived credentials via AWS OIDC (no long-lived AWS keys stored in GitHub).

## Project Structure

```
devops-project/
├── app/                          # FastAPI application
├── tests/                        # Pytest unit tests
├── Dockerfile                     # Multi-stage, non-root container build
├── .github/workflows/deploy.yml  # CI/CD pipeline
├── terraform/                     # AWS infrastructure (VPC, EKS, ECR, IAM, monitoring)
├── helm/fastapi-app/              # Helm chart (Deployment, Service, ServiceMonitor, alerts)
└── argocd/application-dev.yaml   # Argo CD GitOps application
```

## Notes

Several values in `terraform/` (AWS account ID in `helm/fastapi-app/values.yaml`, the OIDC subject in `oidc.tf`, the Grafana admin password and alert webhook URL in `monitoring.tf`) are placeholders from the original setup and should be replaced with your own before deploying to a real AWS account.
