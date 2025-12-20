provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.cluster_name,
      "--region",
      var.region
    ]
  }
  alias = "eks"
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        module.eks.cluster_name,
        "--region",
        var.region
      ]
    }
  }
  alias = "eks"
}

module "observability" {
  source           = "./modules/observability"
  eks_cluster_name = module.eks.cluster_name
  
  providers = {
    kubernetes = kubernetes.eks
    helm       = helm.eks
  }
  
  depends_on = [module.eks]
}

module "apps" {
  source           = "./modules/apps"
  eks_cluster_name = module.eks.cluster_name
  
  providers = {
    kubernetes = kubernetes.eks
  }
  
  depends_on = [module.eks]
}