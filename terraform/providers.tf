terraform {
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
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}

# Local k3s provider configuration
provider "k3s" {
  # Configuration for local k3s installation
  # The provider will automatically detect k3s if installed
}

# Kubernetes provider configuration
provider "kubernetes" {
  config_path = pathexpand("~/.kube/config")
  
  # Override for local development
  host = "https://127.0.0.1:6443"
  
  # Insecure skip TLS verification for local development
  insecure = true
}

# Helm provider configuration
provider "helm" {
  kubernetes {
    config_path = pathexpand("~/.kube/config")
    host         = "https://127.0.0.1:6443"
    insecure     = true
  }
}
