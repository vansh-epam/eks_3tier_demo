# EKS Observability First Platform

A complete Terraform-based solution for deploying an Amazon EKS cluster with built-in observability stack and sample applications.

## Description

This project provisions a production-ready EKS cluster on AWS with:
- **VPC Infrastructure**: Custom VPC with public/private subnets across multiple AZs
- **EKS Cluster**: Kubernetes 1.32 with managed node groups
- **Observability Stack**: Prometheus and Grafana via Helm charts
- **Sample Applications**: Frontend and API deployments for testing

## Directory Structure

```
eks-observability-first-platform/
├── modules/
│   ├── vpc/                    # VPC module
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── eks/                    # EKS cluster module
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── observability/          # Prometheus/Grafana stack
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── versions.tf
│   └── apps/                   # Sample applications
│       ├── main.tf
│       ├── variables.tf
│       └── versions.tf
├── main.tf                     # Root module
├── variables.tf                # Input variables
├── outputs.tf                  # Output values
├── providers.tf                # Provider configurations
├── kubernetes.tf               # Kubernetes/Helm providers
├── versions.tf                 # Version constraints
├── terraform.tfvars            # Variable values
└── .terraform.lock.hcl         # Dependency lock file
```

## Prerequisites

- **AWS CLI** configured with appropriate credentials
- **Terraform** >= 1.0
- **kubectl** for cluster management
- **Helm** for package management
- AWS IAM permissions for EKS, VPC, and EC2 resources

## High‑Level Architecture

```
Frontend (NGINX)
     │
Backend API (CPU‑scaled)
     │
External Data Services (extensible)

Observability Plane:
Prometheus + Grafana (separate namespace)
```

## Configuration

Edit `terraform.tfvars` to customize your deployment:

```hcl
region = "ap-south-1"
cluster_name = "eks-3tier-demo"
vpc_cidr = "10.0.0.0/16"
node_desired_size = 2
node_min_size = 1
node_max_size = 4
node_instance_type = "t3.medium"
```

## Deployment

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Plan the deployment**:
   ```bash
   terraform plan
   ```

3. **Apply the configuration**:
   ```bash
   terraform apply
   ```

4. **Configure kubectl**:
   ```bash
   aws eks update-kubeconfig --region ap-south-1 --name eks-3tier-demo
   ```

## Accessing Services

- **Kubernetes Dashboard**: Use `kubectl proxy` and access via localhost
- **Prometheus**: Port-forward to access the monitoring interface
- **Grafana**: Port-forward to access dashboards (default: admin/prom-operator)

```bash
# Access Prometheus
kubectl port-forward -n observability svc/kube-prometheus-kube-prome-prometheus 9090:9090

# Access Grafana
kubectl port-forward -n observability svc/kube-prometheus-grafana 3000:80
```
Open browser:
```
http://localhost:3000
```

Login:
- Username: admin
- Password: retrieve from Kubernetes secret


## Cleanup

To destroy all resources:

```bash
terraform destroy
```

## Security Notes

- State files (`terraform.tfstate`) are excluded from version control
- Uses AWS IAM roles for service authentication
- Cluster endpoint has both private and public access enabled
- Node groups use managed scaling

## Cost Considerations

- EKS cluster: ~$73/month
- t3.medium nodes: ~$30/month per node
- NAT Gateway: ~$45/month
- Total estimated cost: ~$150-200/month

Use the [AWS Pricing Calculator](https://calculator.aws) for detailed estimates.