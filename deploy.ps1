# eShop WebForms Kubernetes Deployment Script for Windows PowerShell

Write-Host "Deploying eShop WebForms to Kubernetes..." -ForegroundColor Green

# Check if kubectl is available
if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Write-Error "kubectl is not installed or not in PATH. Please install kubectl first."
    exit 1
}

# Create namespace
Write-Host "Creating namespace..." -ForegroundColor Yellow
kubectl apply -f k8s/namespace.yaml

# Create persistent volume claim for SQL Server
Write-Host "Creating SQL Server persistent volume claim..." -ForegroundColor Yellow
kubectl apply -f k8s/sqlserver-pvc.yaml

# Create secrets and config maps
Write-Host "Creating secrets and config maps..." -ForegroundColor Yellow
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/configmap.yaml

# Deploy SQL Server
Write-Host "Deploying SQL Server..." -ForegroundColor Yellow
kubectl apply -f k8s/sqlserver.yaml

# Wait for SQL Server to be ready
Write-Host "Waiting for SQL Server to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=sqlserver -n eshop --timeout=300s

if ($LASTEXITCODE -ne 0) {
    Write-Warning "SQL Server readiness check timed out. Continuing with deployment..."
}

# Deploy web application
Write-Host "Deploying web application..." -ForegroundColor Yellow
kubectl apply -f k8s/webapp.yaml

# Wait for web application to be ready
Write-Host "Waiting for web application to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=eshop-webforms -n eshop --timeout=300s

if ($LASTEXITCODE -ne 0) {
    Write-Warning "Web application readiness check timed out."
}

# Optionally deploy ingress
$deployIngress = Read-Host "Deploy ingress for external access? (y/N)"
if ($deployIngress -eq 'y' -or $deployIngress -eq 'Y') {
    Write-Host "Deploying ingress..." -ForegroundColor Yellow
    kubectl apply -f k8s/ingress.yaml
}

Write-Host "Deployment completed!" -ForegroundColor Green
Write-Host ""
Write-Host "To check the status of your deployment:" -ForegroundColor Cyan
Write-Host "  kubectl get pods -n eshop"
Write-Host "  kubectl get services -n eshop"
Write-Host ""
Write-Host "To access the application:" -ForegroundColor Cyan
Write-Host "  kubectl port-forward service/eshop-webforms-service 8080:80 -n eshop"
Write-Host "  Then open http://localhost:8080 in your browser"
Write-Host ""
Write-Host "To view logs:" -ForegroundColor Cyan
Write-Host "  kubectl logs -l app=eshop-webforms -n eshop"
Write-Host "  kubectl logs -l app=sqlserver -n eshop"