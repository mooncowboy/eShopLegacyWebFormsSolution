#!/bin/bash

# Kubernetes Manifest Validation Script (Syntax Only)

echo "Validating Kubernetes manifests syntax..."

# Function to check YAML syntax (supports multiple documents)
check_yaml() {
    local file=$1
    if python3 -c "
import yaml
with open('$file', 'r') as f:
    docs = yaml.safe_load_all(f)
    for doc in docs:
        pass
" 2>/dev/null; then
        echo "  ✓ $file has valid YAML syntax"
        return 0
    else
        echo "  ✗ $file has invalid YAML syntax"
        python3 -c "
import yaml
with open('$file', 'r') as f:
    docs = yaml.safe_load_all(f)
    for doc in docs:
        pass
" 2>&1
        return 1
    fi
}

# Check if python3 is available
if ! command -v python3 &> /dev/null; then
    echo "Error: python3 is not installed"
    exit 1
fi

# Validate all YAML files in k8s directory
echo "Validating YAML syntax..."
has_errors=false

for file in k8s/*.yaml; do
    if [ -f "$file" ]; then
        echo "Checking $file..."
        if ! check_yaml "$file"; then
            has_errors=true
        fi
    fi
done

# Check production files if they exist
if [ -d "k8s-production" ]; then
    echo ""
    echo "Checking production files..."
    for file in k8s-production/*.yaml; do
        if [ -f "$file" ]; then
            echo "Checking $file..."
            if ! check_yaml "$file"; then
                has_errors=true
            fi
        fi
    done
fi

# Validate kustomization (basic syntax)
echo ""
echo "Validating kustomization syntax..."
if command -v kustomize &> /dev/null; then
    if kustomize build k8s/ > /dev/null 2>&1; then
        echo "  ✓ Base kustomization builds successfully"
    else
        echo "  ✗ Base kustomization has errors"
        kustomize build k8s/ 2>&1
        has_errors=true
    fi
else
    echo "  ⚠ kustomize not found, skipping kustomization validation"
fi

echo ""
if [ "$has_errors" = true ]; then
    echo "❌ Validation completed with errors!"
    exit 1
else
    echo "✅ All validations passed!"
    exit 0
fi