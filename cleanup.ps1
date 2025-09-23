# eShop WebForms Kubernetes Cleanup Script for Windows PowerShell

Write-Host "Cleaning up eShop WebForms deployment..." -ForegroundColor Red

# Check if kubectl is available
if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Write-Error "kubectl is not installed or not in PATH. Please install kubectl first."
    exit 1
}

# Delete ingress (if exists)
Write-Host "Removing ingress..." -ForegroundColor Yellow
kubectl delete -f k8s/ingress.yaml --ignore-not-found=true

# Delete web application
Write-Host "Removing web application..." -ForegroundColor Yellow
kubectl delete -f k8s/webapp.yaml --ignore-not-found=true

# Delete SQL Server
Write-Host "Removing SQL Server..." -ForegroundColor Yellow
kubectl delete -f k8s/sqlserver.yaml --ignore-not-found=true

# Delete secrets and config maps
Write-Host "Removing secrets and config maps..." -ForegroundColor Yellow
kubectl delete -f k8s/secrets.yaml --ignore-not-found=true
kubectl delete -f k8s/configmap.yaml --ignore-not-found=true

# Delete persistent volume claim (WARNING: This will delete data!)
Write-Host "WARNING: About to delete persistent volume claim. This will delete all database data!" -ForegroundColor Red
$response = Read-Host "Are you sure you want to continue? (y/N)"

if ($response -eq 'y' -or $response -eq 'Y') {
    Write-Host "Removing persistent volume claim..." -ForegroundColor Yellow
    kubectl delete -f k8s/sqlserver-pvc.yaml --ignore-not-found=true
} else {
    Write-Host "Skipping PVC deletion. To remove manually:" -ForegroundColor Yellow
    Write-Host "  kubectl delete -f k8s/sqlserver-pvc.yaml"
}

# Delete namespace
Write-Host "Removing namespace..." -ForegroundColor Yellow
kubectl delete -f k8s/namespace.yaml --ignore-not-found=true

Write-Host "Cleanup completed!" -ForegroundColor Green