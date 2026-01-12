output "cluster_name" {
  description = "Name of the k3s cluster"
  value       = k3s_cluster.cloudforge.name
}

output "cluster_version" {
  description = "Version of the k3s cluster"
  value       = k3s_cluster.cloudforge.version
}

output "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  value       = pathexpand("~/.kube/config")
}

output "namespace" {
  description = "Kubernetes namespace for CloudForge"
  value       = kubernetes_namespace.cloudforge.metadata[0].name
}

output "ingress_http_port" {
  description = "HTTP port for ingress"
  value       = "30080"
}

output "ingress_https_port" {
  description = "HTTPS port for ingress"
  value       = "30443"
}

output "ingress_host" {
  description = "Host name for ingress"
  value       = var.ingress_host
}

output "storage_class" {
  description = "Storage class name"
  value       = kubernetes_storage_class.local_storage.metadata[0].name
}

output "frontend_url" {
  description = "URL to access the frontend"
  value       = "http://localhost:30080"
}

output "api_base_url" {
  description = "Base URL for API endpoints"
  value       = "http://localhost:30080/api"
}
