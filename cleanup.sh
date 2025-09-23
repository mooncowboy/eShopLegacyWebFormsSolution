#!/bin/bash

# eShop WebForms Kubernetes Cleanup Script

echo "Cleaning up eShop WebForms deployment..."

# Delete ingress (if exists)
echo "Removing ingress..."
kubectl delete -f k8s/ingress.yaml --ignore-not-found=true

# Delete web application
echo "Removing web application..."
kubectl delete -f k8s/webapp.yaml --ignore-not-found=true

# Delete SQL Server
echo "Removing SQL Server..."
kubectl delete -f k8s/sqlserver.yaml --ignore-not-found=true

# Delete secrets and config maps
echo "Removing secrets and config maps..."
kubectl delete -f k8s/secrets.yaml --ignore-not-found=true
kubectl delete -f k8s/configmap.yaml --ignore-not-found=true

# Delete persistent volume claim (WARNING: This will delete data!)
echo "WARNING: About to delete persistent volume claim. This will delete all database data!"
read -p "Are you sure you want to continue? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Removing persistent volume claim..."
    kubectl delete -f k8s/sqlserver-pvc.yaml --ignore-not-found=true
else
    echo "Skipping PVC deletion. To remove manually:"
    echo "  kubectl delete -f k8s/sqlserver-pvc.yaml"
fi

# Delete namespace
echo "Removing namespace..."
kubectl delete -f k8s/namespace.yaml --ignore-not-found=true

echo "Cleanup completed!"