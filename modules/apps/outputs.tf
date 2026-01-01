output "ingress_hostname" {
  description = "The hostname of the ALB ingress"
  value       = try(kubernetes_ingress_v1.main.status[0].load_balancer[0].ingress[0].hostname, "")
}
