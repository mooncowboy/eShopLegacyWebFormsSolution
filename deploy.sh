#!/bin/bash

# eShop WebForms Kubernetes Deployment Script

echo "Deploying eShop WebForms to Kubernetes..."

# Create namespace
echo "Creating namespace..."
kubectl apply -f k8s/namespace.yaml

# Create persistent volume claim for SQL Server
echo "Creating SQL Server persistent volume claim..."
kubectl apply -f k8s/sqlserver-pvc.yaml

# Create secrets and config maps
echo "Creating secrets and config maps..."
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/configmap.yaml

# Deploy SQL Server
echo "Deploying SQL Server..."
kubectl apply -f k8s/sqlserver.yaml

# Wait for SQL Server to be ready
echo "Waiting for SQL Server to be ready..."
kubectl wait --for=condition=ready pod -l app=sqlserver -n eshop --timeout=300s

# Deploy web application
echo "Deploying web application..."
kubectl apply -f k8s/webapp.yaml

# Wait for web application to be ready
echo "Waiting for web application to be ready..."
kubectl wait --for=condition=ready pod -l app=eshop-webforms -n eshop --timeout=300s

# Optionally deploy ingress (uncomment if needed)
# echo "Deploying ingress..."
# kubectl apply -f k8s/ingress.yaml

echo "Deployment completed!"
echo ""
echo "To check the status of your deployment:"
echo "  kubectl get pods -n eshop"
echo "  kubectl get services -n eshop"
echo ""
echo "To access the application:"
echo "  kubectl port-forward service/eshop-webforms-service 8080:80 -n eshop"
echo "  Then open http://localhost:8080 in your browser"
echo ""
echo "To view logs:"
echo "  kubectl logs -l app=eshop-webforms -n eshop"
echo "  kubectl logs -l app=sqlserver -n eshop"