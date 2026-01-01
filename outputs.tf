output "cluster_name" {
  value = module.eks.cluster_name
}

output "alb_hostname" {
  description = "The hostname of the Application Load Balancer"
  value       = module.apps.ingress_hostname
}

output "frontend_url" {
  description = "URL to access the frontend application"
  value       = "http://${module.apps.ingress_hostname}/"
}

output "api_url" {
  description = "URL to access the API"
  value       = "http://${module.apps.ingress_hostname}/api"
}
