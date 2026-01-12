#!/bin/bash

# CloudForge Secure Platform Build Script
# This script builds all microservice images using Podman and deploys to Kubernetes

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="cloudforge"
REGISTRY="localhost"
IMAGE_TAG=${IMAGE_TAG:-"latest"}
PUSH_IMAGES=${PUSH_IMAGES:-"false"}
APPLY_K8S=${APPLY_K8S:-"true"}
RUN_TERRAFORM=${RUN_TERRAFORM:-"false"}

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command_exists podman; then
        print_error "Podman is not installed. Please install Podman first."
        exit 1
    fi
    
    if ! command_exists kubectl; then
        print_error "kubectl is not installed. Please install kubectl first."
        exit 1
    fi
    
    if [ "$RUN_TERRAFORM" = "true" ] && ! command_exists terraform; then
        print_error "Terraform is not installed. Please install Terraform first."
        exit 1
    fi
    
    # Check if k3s is running when using Terraform
    if [ "$RUN_TERRAFORM" = "true" ]; then
        if ! command_exists k3s; then
            print_error "k3s is not installed. Please install k3s first."
            exit 1
        fi
        
        if ! pgrep -x "k3s" > /dev/null; then
            print_warning "k3s is not running. Starting k3s..."
            sudo k3s server --disable=traefik --write-kubeconfig-mode=644 &
            sleep 10
        fi
    fi
    
    print_success "Prerequisites check passed!"
}

# Function to build images with Podman
build_images() {
    print_status "Building microservice images with Podman..."
    
    # Build auth service image
    print_status "Building auth service image..."
    cd services/auth
    podman build -t ${REGISTRY}/${PROJECT_NAME}-auth:${IMAGE_TAG} .
    cd ../..
    
    # Build users service image
    print_status "Building users service image..."
    cd services/users
    podman build -t ${REGISTRY}/${PROJECT_NAME}-users:${IMAGE_TAG} .
    cd ../..
    
    # Build frontend image
    print_status "Building frontend image..."
    cd services/frontend
    podman build -t ${REGISTRY}/${PROJECT_NAME}-frontend:${IMAGE_TAG} .
    cd ../..
    
    print_success "All images built successfully!"
}

# Function to push images to registry
push_images() {
    if [ "$PUSH_IMAGES" = "true" ]; then
        print_status "Pushing images to registry..."
        
        # Start local registry if not running
        if ! podman ps | grep -q "localhost:5000"; then
            print_status "Starting local registry..."
            podman run -d -p 5000:5000 --name local-registry registry:2
            sleep 5
        fi
        
        # Push images
        podman push ${REGISTRY}/${PROJECT_NAME}-auth:${IMAGE_TAG}
        podman push ${REGISTRY}/${PROJECT_NAME}-users:${IMAGE_TAG}
        podman push ${REGISTRY}/${PROJECT_NAME}-frontend:${IMAGE_TAG}
        
        print_success "Images pushed to registry successfully!"
    else
        print_warning "Skipping image push (PUSH_IMAGES=false)"
    fi
}

# Function to run Terraform
run_terraform() {
    if [ "$RUN_TERRAFORM" = "true" ]; then
        print_status "Running Terraform to provision infrastructure..."
        
        cd terraform
        
        # Initialize Terraform
        print_status "Initializing Terraform..."
        terraform init
        
        # Plan and apply
        print_status "Planning Terraform changes..."
        terraform plan
        
        print_status "Applying Terraform changes..."
        terraform apply -auto-approve
        
        cd ..
        print_success "Terraform infrastructure provisioned successfully!"
    else
        print_warning "Skipping Terraform (RUN_TERRAFORM=false)"
    fi
}

# Function to deploy to Kubernetes
deploy_kubernetes() {
    if [ "$APPLY_K8S" = "true" ]; then
        print_status "Deploying to Kubernetes..."
        
        # Wait for Kubernetes to be ready
        print_status "Waiting for Kubernetes cluster to be ready..."
        kubectl wait --for=condition=ready node --all --timeout=300s
        
        # Apply namespace
        print_status "Applying namespace..."
        kubectl apply -f k8s/namespace.yaml
        
        # Apply ConfigMaps and Secrets
        print_status "Applying ConfigMaps and Secrets..."
        kubectl apply -f k8s/configmap.yaml
        kubectl apply -f k8s/secrets.yaml
        
        # Apply deployments and services
        print_status "Applying deployments and services..."
        kubectl apply -f k8s/auth-deployment.yaml
        kubectl apply -f k8s/auth-service.yaml
        kubectl apply -f k8s/users-deployment.yaml
        kubectl apply -f k8s/users-service.yaml
        kubectl apply -f k8s/frontend-deployment.yaml
        kubectl apply -f k8s/frontend-service.yaml
        
        # Apply ingress
        print_status "Applying ingress..."
        kubectl apply -f k8s/ingress.yaml
        
        # Wait for deployments to be ready
        print_status "Waiting for deployments to be ready..."
        kubectl wait --for=condition=available --timeout=300s deployment/auth-deployment -n cloudforge
        kubectl wait --for=condition=available --timeout=300s deployment/users-deployment -n cloudforge
        kubectl wait --for=condition=available --timeout=300s deployment/frontend-deployment -n cloudforge
        
        print_success "Kubernetes deployment completed successfully!"
    else
        print_warning "Skipping Kubernetes deployment (APPLY_K8S=false)"
    fi
}

# Function to show deployment status
show_status() {
    print_status "Deployment Status:"
    echo ""
    
    if command_exists kubectl; then
        echo "=== Pods ==="
        kubectl get pods -n cloudforge
        echo ""
        
        echo "=== Services ==="
        kubectl get services -n cloudforge
        echo ""
        
        echo "=== Ingress ==="
        kubectl get ingress -n cloudforge
        echo ""
        
        echo "=== Access URLs ==="
        echo "Frontend: http://localhost:30080"
        echo "API: http://localhost:30080/api"
        echo ""
    fi
}

# Function to cleanup
cleanup() {
    print_status "Cleaning up..."
    
    # Remove temporary containers
    if podman ps -a | grep -q "temp-"; then
        podman rm -f $(podman ps -a --filter "name=temp-" -q)
    fi
    
    print_success "Cleanup completed!"
}

# Main execution
main() {
    print_status "Starting CloudForge Secure Platform build and deployment..."
    echo ""
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --push-images)
                PUSH_IMAGES="true"
                shift
                ;;
            --no-k8s)
                APPLY_K8S="false"
                shift
                ;;
            --terraform)
                RUN_TERRAFORM="true"
                shift
                ;;
            --tag)
                IMAGE_TAG="$2"
                shift 2
                ;;
            --help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --push-images    Push images to local registry"
                echo "  --no-k8s         Skip Kubernetes deployment"
                echo "  --terraform      Run Terraform to provision infrastructure"
                echo "  --tag TAG        Use specific image tag (default: latest)"
                echo "  --help           Show this help message"
                echo ""
                echo "Environment Variables:"
                echo "  PUSH_IMAGES      Push images to registry (default: false)"
                echo "  APPLY_K8S        Apply Kubernetes manifests (default: true)"
                echo "  RUN_TERRAFORM    Run Terraform (default: false)"
                echo "  IMAGE_TAG        Image tag to use (default: latest)"
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Execute build and deployment steps
    check_prerequisites
    build_images
    push_images
    run_terraform
    deploy_kubernetes
    show_status
    cleanup
    
    print_success "CloudForge Secure Platform build and deployment completed!"
    echo ""
    echo "Next steps:"
    echo "1. Access the frontend at: http://localhost:30080"
    echo "2. Test the API endpoints at: http://localhost:30080/api"
    echo "3. Check pod status with: kubectl get pods -n cloudforge"
    echo "4. View logs with: kubectl logs -f deployment/auth-deployment -n cloudforge"
}

# Handle script interruption
trap cleanup EXIT

# Run main function
main "$@"
