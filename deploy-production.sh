#!/bin/bash

# Production Deployment Script

echo "Deploying eShop WebForms to Production Kubernetes Environment..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed or not in PATH"
    exit 1
fi

# Confirm production deployment
echo "⚠️  This will deploy to PRODUCTION environment!"
read -p "Are you sure you want to continue? (yes/NO): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Deployment cancelled."
    exit 0
fi

# Create namespace
echo "Creating production namespace..."
kubectl apply -f k8s-production/namespace.yaml

# Create persistent volume claim for SQL Server
echo "Creating SQL Server persistent volume claim..."
sed 's/namespace: eshop/namespace: eshop-prod/' k8s/sqlserver-pvc.yaml | kubectl apply -f -

# Create secrets and config maps (production versions)
echo "Creating production secrets and config maps..."
sed 's/namespace: eshop/namespace: eshop-prod/' k8s/secrets.yaml | kubectl apply -f -
kubectl apply -f k8s-production/configmap.yaml

# Deploy SQL Server (with production resources)
echo "Deploying SQL Server with production configuration..."
sed 's/namespace: eshop/namespace: eshop-prod/' k8s/sqlserver.yaml | \
sed 's/memory: "2Gi"/memory: "4Gi"/' | \
sed 's/cpu: "500m"/cpu: "1000m"/' | \
sed 's/memory: "4Gi"/memory: "8Gi"/' | \
sed 's/cpu: "1000m"/cpu: "2000m"/' | \
kubectl apply -f -

# Wait for SQL Server to be ready
echo "Waiting for SQL Server to be ready..."
kubectl wait --for=condition=ready pod -l app=sqlserver -n eshop-prod --timeout=300s

# Deploy web application (with production configuration)
echo "Deploying web application with production configuration..."
sed 's/namespace: eshop/namespace: eshop-prod/' k8s/webapp.yaml | \
sed 's/replicas: 2/replicas: 3/' | \
sed 's/memory: "1Gi"/memory: "2Gi"/' | \
sed 's/cpu: "250m"/cpu: "500m"/' | \
sed 's/memory: "2Gi"/memory: "4Gi"/' | \
sed 's/cpu: "500m"/cpu: "1000m"/' | \
kubectl apply -f -

# Wait for web application to be ready
echo "Waiting for web application to be ready..."
kubectl wait --for=condition=ready pod -l app=eshop-webforms -n eshop-prod --timeout=300s

echo "Production deployment completed!"
echo ""
echo "To check the status of your production deployment:"
echo "  kubectl get pods -n eshop-prod"
echo "  kubectl get services -n eshop-prod"
echo ""
echo "To access the application:"
echo "  kubectl port-forward service/eshop-webforms-service 8080:80 -n eshop-prod"