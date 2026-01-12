# Local k3s Kubernetes cluster for CloudForge Platform

terraform {
  required_version = ">= 1.0"
  required_providers {
    k3s = {
      source  = "k3s-io/k3s"
      version = "~> 0.6"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.9"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

# Configure k3s provider
provider "k3s" {
  # Use local k3s installation
  # This assumes k3s is installed locally
}

# Configure Kubernetes provider
provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Configure Helm provider
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

# Create k3s cluster (if not already running)
resource "k3s_cluster" "cloudforge" {
  name        = "cloudforge-cluster"
  version     = var.k3s_version
  extra_args  = ["--disable=traefik", "--write-kubeconfig-mode=644"]
  
  # Network configuration
  network {
    pod_cidr     = var.pod_cidr
    service_cidr = var.service_cidr
  }
}

# Wait for cluster to be ready
resource "time_sleep" "wait_for_cluster" {
  depends_on = [k3s_cluster.cloudforge]
  create_duration = "30s"
}

# Create namespace
resource "kubernetes_namespace" "cloudforge" {
  metadata {
    name = var.namespace
    labels = {
      name        = var.namespace
      environment = var.environment
    }
  }

  depends_on = [time_sleep.wait_for_cluster]
}

# Create storage class for persistent volumes
resource "kubernetes_storage_class" "local_storage" {
  metadata {
    name = "local-storage"
  }

  storage_provisioner = "kubernetes.io/no-provisioner"
  volume_binding_mode = "WaitForFirstConsumer"

  reclaim_policy = "Delete"

  depends_on = [kubernetes_namespace.cloudforge]
}

# Deploy NGINX Ingress Controller
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  create_namespace = true

  set {
    name  = "controller.service.type"
    value = "NodePort"
  }

  set {
    name  = "controller.service.nodePorts.http"
    value = "30080"
  }

  set {
    name  = "controller.service.nodePorts.https"
    value = "30443"
  }

  depends_on = [kubernetes_namespace.cloudforge]
}

# Create ConfigMap for application configuration
resource "kubernetes_config_map" "cloudforge_config" {
  metadata {
    name      = "cloudforge-config"
    namespace = var.namespace
  }

  data = {
    AUTH_SERVICE_URL   = "http://auth-service:8001"
    USERS_SERVICE_URL  = "http://users-service:8002"
    FRONTEND_URL      = "http://frontend-service:3000"
    LOG_LEVEL         = "INFO"
    ENVIRONMENT       = var.environment
  }

  depends_on = [kubernetes_namespace.cloudforge]
}

# Create Secret for sensitive data
resource "kubernetes_secret" "cloudforge_secrets" {
  metadata {
    name      = "cloudforge-secrets"
    namespace = var.namespace
  }

  type = "Opaque"

  data = {
    SECRET_KEY     = base64encode(var.secret_key)
    DATABASE_URL   = base64encode(var.database_url)
    REDIS_URL      = base64encode(var.redis_url)
  }

  depends_on = [kubernetes_namespace.cloudforge]
}

# Output cluster information
output "cluster_info" {
  value = {
    name        = k3s_cluster.cloudforge.name
    version     = k3s_cluster.cloudforge.version
    kubeconfig  = pathexpand("~/.kube/config")
    namespace   = kubernetes_namespace.cloudforge.metadata[0].name
  }
}

output "ingress_info" {
  value = {
    http_port  = "30080"
    https_port = "30443"
    host       = "cloudforge.local"
  }
}
