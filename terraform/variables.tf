variable "k3s_version" {
  description = "Version of k3s to install"
  type        = string
  default     = "v1.28.3+k3s.1"
}

variable "namespace" {
  description = "Kubernetes namespace for CloudForge"
  type        = string
  default     = "cloudforge"
}

variable "environment" {
  description = "Environment name (development, staging, production)"
  type        = string
  default     = "development"
}

variable "pod_cidr" {
  description = "CIDR block for Kubernetes pods"
  type        = string
  default     = "10.42.0.0/16"
}

variable "service_cidr" {
  description = "CIDR block for Kubernetes services"
  type        = string
  default     = "10.43.0.0/16"
}

variable "secret_key" {
  description = "Secret key for JWT token generation"
  type        = string
  default     = "your-secret-key-change-in-production"
  sensitive   = true
}

variable "database_url" {
  description = "Database connection URL"
  type        = string
  default     = "mongodb://localhost:27017"
  sensitive   = true
}

variable "redis_url" {
  description = "Redis connection URL"
  type        = string
  default     = "redis://localhost:6379"
  sensitive   = true
}

variable "ingress_host" {
  description = "Host name for ingress"
  type        = string
  default     = "cloudforge.local"
}

variable "enable_monitoring" {
  description = "Enable monitoring stack (prometheus, grafana)"
  type        = bool
  default     = false
}

variable "enable_logging" {
  description = "Enable logging stack (elasticsearch, kibana)"
  type        = bool
  default     = false
}
