# CloudForge Secure Platform

A cloud-native microservices platform built with **Podman**, **Kubernetes**, and **Terraform**. This project demonstrates secure, scalable architecture for modern applications using rootless containers and infrastructure as code.

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        CloudForge Platform                      │
├─────────────────────────────────────────────────────────────────┤
│  Frontend (React)                                               │
│  ┌─────────────────┐                                           │
│  │   nginx:3000    │                                           │
│  └─────────────────┘                                           │
│           │                                                     │
│           ▼                                                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    Ingress Controller                   │   │
│  │              (nginx-ingress:30080)                      │   │
│  └─────────────────────────────────────────────────────────┘   │
│           │                                                     │
│           ▼                                                     │
│  ┌─────────────────┐  ┌─────────────────┐                     │
│  │  Auth Service   │  │  Users Service  │                     │
│  │  FastAPI:8001   │  │  FastAPI:8002   │                     │
│  └─────────────────┘  └─────────────────┘                     │
└─────────────────────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                         │
│                      (k3s local)                              │
└─────────────────────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Infrastructure as Code                      │
│                        (Terraform)                            │
└─────────────────────────────────────────────────────────────────┘
```

## 🚀 Features

- **Rootless Podman**: Secure container runtime without root privileges
- **Microservices Architecture**: Auth and Users services with FastAPI
- **Modern Frontend**: React with Tailwind CSS and nginx
- **Kubernetes Native**: Complete K8s manifests for deployment
- **Infrastructure as Code**: Terraform for k3s cluster provisioning
- **Security First**: JWT authentication, secrets management
- **Cloud Ready**: Designed for easy cloud deployment
- **Developer Friendly**: Automated build and deployment scripts

## 📁 Project Structure

```
cloudforge/
├── services/
│   ├── auth/                    # Authentication microservice
│   │   ├── main.py            # FastAPI application
│   │   ├── requirements.txt   # Python dependencies
│   │   └── Dockerfile         # Podman-compatible container
│   ├── users/                  # User management microservice
│   │   ├── main.py            # FastAPI application
│   │   ├── requirements.txt   # Python dependencies
│   │   └── Dockerfile         # Podman-compatible container
│   └── frontend/               # React frontend application
│       ├── src/               # React source code
│       ├── public/            # Static assets
│       ├── package.json       # Node.js dependencies
│       ├── Dockerfile         # Multi-stage build
│       └── nginx.conf         # nginx configuration
├── k8s/                        # Kubernetes manifests
│   ├── namespace.yaml         # CloudForge namespace
│   ├── configmap.yaml         # Application configuration
│   ├── secrets.yaml           # Sensitive data
│   ├── auth-deployment.yaml   # Auth service deployment
│   ├── auth-service.yaml      # Auth service endpoint
│   ├── users-deployment.yaml  # Users service deployment
│   ├── users-service.yaml     # Users service endpoint
│   ├── frontend-deployment.yaml # Frontend deployment
│   ├── frontend-service.yaml  # Frontend service endpoint
│   └── ingress.yaml           # Ingress configuration
├── terraform/                  # Infrastructure as Code
│   ├── main.tf               # Main Terraform configuration
│   ├── providers.tf          # Provider configurations
│   ├── variables.tf          # Input variables
│   └── outputs.tf            # Output values
├── scripts/
│   └── build.sh              # Automated build and deployment
└── README.md                 # This file
```

## 🛠️ Prerequisites

### Required Tools

1. **Podman** (v4.0+)
   ```bash
   # Ubuntu/Debian
   sudo apt update && sudo apt install podman
   
   # RHEL/CentOS
   sudo dnf install podman
   
   # macOS
   brew install podman
   ```

2. **kubectl** (v1.28+)
   ```bash
   curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
   sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
   ```

3. **k3s** (optional, for local Kubernetes)
   ```bash
   curl -sfL https://get.k3s.io | sh -
   ```

4. **Terraform** (v1.0+, optional)
   ```bash
   # Install Terraform
   curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
   sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
   sudo apt-get update && sudo apt-get install terraform
   ```

### Optional Tools

- **Node.js** (v18+) - for frontend development
- **Python** (v3.11+) - for backend development
- **Docker** - alternative to Podman (not recommended)

## 🚀 Quick Start

### 1. Clone and Build

```bash
# Clone the repository
git clone <repository-url>
cd cloudforge

# Make build script executable
chmod +x scripts/build.sh

# Build and deploy everything
./scripts/build.sh
```

### 2. Access the Platform

Once deployment is complete, access the platform at:

- **Frontend**: http://localhost:30080
- **Auth API**: http://localhost:30080/api/auth
- **Users API**: http://localhost:30080/api/users

### 3. Test Authentication

```bash
# Get JWT token
curl -X POST http://localhost:30080/api/auth/token \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}'

# Use token to access protected endpoint
curl -X GET http://localhost:30080/api/users/me \
  -H "Authorization: Bearer <YOUR_TOKEN>"
```

## 📋 Build Script Options

The `build.sh` script provides several options:

```bash
# Basic build and deploy
./scripts/build.sh

# Build and push images to local registry
./scripts/build.sh --push-images

# Run Terraform to provision infrastructure
./scripts/build.sh --terraform

# Use custom image tag
./scripts/build.sh --tag v1.0.0

# Skip Kubernetes deployment
./scripts/build.sh --no-k8s

# Show help
./scripts/build.sh --help
```

### Environment Variables

- `PUSH_IMAGES`: Push images to registry (default: false)
- `APPLY_K8S`: Apply Kubernetes manifests (default: true)
- `RUN_TERRAFORM`: Run Terraform (default: false)
- `IMAGE_TAG`: Image tag to use (default: latest)

## 🔧 Development Guide

### Local Development with Podman

```bash
# Build individual services
cd services/auth
podman build -t cloudforge-auth .
podman run -p 8001:8001 cloudforge-auth

cd ../users
podman build -t cloudforge-users .
podman run -p 8002:8002 cloudforge-users

cd ../frontend
podman build -t cloudforge-frontend .
podman run -p 3000:3000 cloudforge-frontend
```

### Kubernetes Development

```bash
# Apply manifests manually
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/auth-deployment.yaml
kubectl apply -f k8s/auth-service.yaml
kubectl apply -f k8s/users-deployment.yaml
kubectl apply -f k8s/users-service.yaml
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/frontend-service.yaml
kubectl apply -f k8s/ingress.yaml

# Check deployment status
kubectl get pods -n cloudforge
kubectl get services -n cloudforge
kubectl get ingress -n cloudforge

# View logs
kubectl logs -f deployment/auth-deployment -n cloudforge
kubectl logs -f deployment/users-deployment -n cloudforge
kubectl logs -f deployment/frontend-deployment -n cloudforge
```

### Terraform Infrastructure

```bash
cd terraform

# Initialize Terraform
terraform init

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy infrastructure
terraform destroy
```

## 🔐 Security Features

- **Rootless Containers**: All containers run without root privileges
- **JWT Authentication**: Secure token-based authentication
- **Secrets Management**: Kubernetes secrets for sensitive data
- **Network Policies**: Service-to-service communication control
- **Health Checks**: Liveness and readiness probes for all services
- **Resource Limits**: CPU and memory constraints

## 📊 Monitoring and Logging

### Health Check Endpoints

- **Auth Service**: `/health`
- **Users Service**: `/health`
- **Frontend**: `/` (nginx status)

### Logs

```bash
# View all service logs
kubectl logs -n cloudforge -l app=auth
kubectl logs -n cloudforge -l app=users
kubectl logs -n cloudforge -l app=frontend

# Follow logs in real-time
kubectl logs -f -n cloudforge deployment/auth-deployment
```

## 🌐 API Documentation

### Auth Service Endpoints

- `POST /token` - Authenticate and get JWT token
- `GET /users/me` - Get current user info
- `POST /validate` - Validate JWT token
- `GET /health` - Health check

### Users Service Endpoints

- `GET /users` - List all users (requires auth)
- `GET /users/{id}` - Get user by ID
- `POST /users` - Create new user
- `PUT /users/{id}` - Update user
- `DELETE /users/{id}` - Delete user
- `GET /health` - Health check

## 🚀 Production Deployment

### Cloud Provider Setup

1. **Update Terraform Variables**
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

2. **Configure Secrets**
   ```bash
   # Update k8s/secrets.yaml with production values
   # Or use Kubernetes secrets management
   ```

3. **Deploy**
   ```bash
   # Deploy infrastructure
   ./scripts/build.sh --terraform
   
   # Deploy applications
   ./scripts/build.sh --push-images
   ```

### Scaling

```bash
# Scale services
kubectl scale deployment auth-deployment --replicas=3 -n cloudforge
kubectl scale deployment users-deployment --replicas=3 -n cloudforge
kubectl scale deployment frontend-deployment --replicas=3 -n cloudforge
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `./scripts/build.sh`
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Troubleshooting

### Common Issues

1. **Podman permission denied**
   ```bash
   # Ensure user is in proper groups
   sudo usermod -aG podman $USER
   
   # Restart session or run:
   newgrp podman
   ```

2. **Kubernetes cluster not ready**
   ```bash
   # Check k3s status
   sudo systemctl status k3s
   
   # Restart if needed
   sudo systemctl restart k3s
   ```

3. **Port conflicts**
   ```bash
   # Check what's using ports
   sudo netstat -tulpn | grep :30080
   
   # Kill conflicting processes
   sudo kill -9 <PID>
   ```

4. **Image pull errors**
   ```bash
   # Check if images exist
   podman images | grep cloudforge
   
   # Rebuild if needed
   ./scripts/build.sh --no-k8s
   ```

### Getting Help

- Check the logs: `kubectl logs -n cloudforge`
- Verify pod status: `kubectl get pods -n cloudforge -o wide`
- Test service connectivity: `kubectl port-forward service/auth-service 8001:8001 -n cloudforge`

## 📚 Additional Resources

- [Podman Documentation](https://docs.podman.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Terraform Documentation](https://www.terraform.io/docs/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [React Documentation](https://reactjs.org/docs/)

---

**Built with ❤️ for cloud-native development**
