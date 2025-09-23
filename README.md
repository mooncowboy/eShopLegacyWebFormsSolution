# eShopLegacyWebFormsSolution

Based on https://github.com/mooncowboy/eShopModernizing/tree/main/eShopLegacyWebFormsSolution

## Overview

This is a modernized version of the eShop Legacy Web Forms application, containerized and ready for deployment on Azure Kubernetes Service (AKS) with Windows containers.

## Application Architecture

- **Web Application**: ASP.NET Web Forms 4.7.2 running on Windows containers
- **Database**: SQL Server 2019 (Linux containers for development, Windows containers for production if needed)
- **Configuration**: Environment variables and Kubernetes secrets
- **Storage**: Optional Azure Blob Storage integration
- **Monitoring**: Optional Application Insights integration

## Prerequisites

### For Local Development with Docker Compose
- Docker Desktop with Windows containers enabled
- At least 8GB RAM available for containers

### For Kubernetes Deployment
- Kubernetes cluster with Windows node pools (AKS with Windows nodes)
- kubectl configured to connect to your cluster
- Container registry (Azure Container Registry recommended)

## Quick Start - Local Development

### Using Docker Compose

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd eShopLegacyWebFormsSolution
   ```

2. **Build and run with Docker Compose**:
   ```bash
   docker-compose up -d
   ```

3. **Access the application**:
   - Web application: http://localhost:8080
   - SQL Server: localhost:5433 (sa/Pass@word123)

4. **Stop the application**:
   ```bash
   docker-compose down
   ```

## Kubernetes Deployment

### Step 1: Build and Push Container Image

1. **Build the Docker image**:
   ```bash
   docker build -t your-registry/eshop-webforms:latest .
   ```

2. **Push to container registry**:
   ```bash
   docker push your-registry/eshop-webforms:latest
   ```

3. **Update the image reference** in `k8s/webapp.yaml`:
   ```yaml
   image: your-registry/eshop-webforms:latest
   ```

### Step 2: Deploy to Kubernetes

#### Option A: Using the deployment script
```bash
./deploy.sh
```

#### Option B: Manual deployment
```bash
# Create namespace
kubectl apply -f k8s/namespace.yaml

# Create persistent storage for SQL Server
kubectl apply -f k8s/sqlserver-pvc.yaml

# Create configuration
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secrets.yaml

# Deploy SQL Server
kubectl apply -f k8s/sqlserver.yaml

# Wait for SQL Server to be ready
kubectl wait --for=condition=ready pod -l app=sqlserver -n eshop --timeout=300s

# Deploy web application
kubectl apply -f k8s/webapp.yaml

# Optional: Deploy ingress for external access
kubectl apply -f k8s/ingress.yaml
```

### Step 3: Access the Application

#### Option A: Port Forward (for testing)
```bash
kubectl port-forward service/eshop-webforms-service 8080:80 -n eshop
```
Then open http://localhost:8080

#### Option B: LoadBalancer (if supported)
```bash
kubectl get services -n eshop
# Use the EXTERNAL-IP of eshop-webforms-service
```

#### Option C: Ingress (if configured)
Configure your DNS to point `eshop.local` to your ingress controller's IP.

## Configuration

### Environment Variables

The application supports the following configuration options:

| Variable | Default | Description |
|----------|---------|-------------|
| `UseMockData` | `true` | Use mock data instead of database |
| `UseAzureStorage` | `false` | Use Azure Blob Storage for images |
| `UseAzureManagedIdentity` | `false` | Use Azure Managed Identity for authentication |
| `UseCustomizationData` | `false` | Use customization data |
| `UseAzureActiveDirectory` | `false` | Enable Azure AD authentication |

### Database Configuration

The application connects to SQL Server using the connection string in the `CatalogDBContext` secret. 

For production deployments:
1. Update the `secrets.yaml` file with your production database connection string
2. Consider using Azure Key Vault integration for secrets management

### Azure Services Integration

#### Azure Storage
To enable Azure Blob Storage for product images:
1. Set `UseAzureStorage=true` in the ConfigMap
2. Update the `StorageConnectionString` in secrets with your Azure Storage connection string

#### Application Insights
To enable monitoring:
1. Update the `AppInsightsInstrumentationKey` in secrets with your Application Insights key

#### Azure Active Directory
To enable Azure AD authentication:
1. Set `UseAzureActiveDirectory=true` in the ConfigMap
2. Update the Azure AD configuration in secrets

## Monitoring and Troubleshooting

### Check Pod Status
```bash
kubectl get pods -n eshop
kubectl describe pod <pod-name> -n eshop
```

### View Logs
```bash
# Web application logs
kubectl logs -l app=eshop-webforms -n eshop

# SQL Server logs
kubectl logs -l app=sqlserver -n eshop

# Follow logs in real-time
kubectl logs -f deployment/eshop-webforms -n eshop
```

### Connect to SQL Server
```bash
# Port forward to SQL Server
kubectl port-forward service/sqlserver-service 1433:1433 -n eshop

# Connect with SQL Server Management Studio or sqlcmd
# Server: localhost,1433
# User: sa
# Password: Pass@word123
```

## Security Considerations

1. **Change default passwords**: Update the SQL Server SA password in secrets.yaml
2. **Use Azure Key Vault**: Consider integrating with Azure Key Vault for production secrets
3. **Network policies**: Implement Kubernetes network policies to restrict traffic
4. **Pod security**: Configure pod security standards and run containers as non-root where possible
5. **Image scanning**: Scan container images for vulnerabilities before deployment

## Scaling

### Horizontal Pod Autoscaler
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: eshop-webforms-hpa
  namespace: eshop
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: eshop-webforms
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

## Cleanup

To remove all resources:
```bash
./cleanup.sh
```

Or manually:
```bash
kubectl delete namespace eshop
```

## Troubleshooting

### Common Issues

1. **Pods stuck in Pending**: Check node selectors and ensure Windows nodes are available
2. **Database connection issues**: Verify SQL Server is running and connection string is correct
3. **Image pull errors**: Ensure the container image is accessible from your cluster
4. **Init container timeout**: SQL Server may take longer to start; increase timeout values

### Useful Commands

```bash
# Scale the application
kubectl scale deployment eshop-webforms --replicas=3 -n eshop

# Update the application
kubectl set image deployment/eshop-webforms eshop-webforms=your-registry/eshop-webforms:new-tag -n eshop

# Restart the application
kubectl rollout restart deployment/eshop-webforms -n eshop

# Check resource usage
kubectl top pods -n eshop
```
