#!/bin/bash

set -e

# Function to detect if remote cluster is AKS
is_remote_aks() {
  # Try to get the providerID of the first node
  provider_id=$(kubectl get nodes -o jsonpath='{.items[0].spec.providerID}' 2>/dev/null)
  if [[ -z "$provider_id" ]]; then
    echo "Warning: Unable to fetch node providerID."
  else
    if [[ "$provider_id" == *"azure"* ]]; then
      return 0
    fi
  fi

  # Check for AKS-related pods in kube-system namespace
  if kubectl get pods -n kube-system 2>/dev/null | grep -q 'azure'; then
    return 0
  fi

  # Additional check: look for AKS-specific configmap or labels
  if kubectl get configmap -n kube-system aks-node-configuration 2>/dev/null >/dev/null; then
    return 0
  fi

  return 1
}

if is_remote_aks; then
  echo "Error: The target Kubernetes cluster is detected as an Azure Kubernetes Service (AKS) cluster."
  echo "This script will not proceed against AKS clusters."
  exit 1
fi

cd ./ingress-nginx
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm dependency build
helm upgrade --install --create-namespace --values=values.yaml -n ingress-nginx ingress-nginx .  --wait --timeout 2m
cd -