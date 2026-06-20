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

helm repo add argo-cd https://argoproj.github.io/argo-helm
# helm repo add kyverno https://kyverno.github.io/kyverno
# helm repo add policy-reporter https://kyverno.github.io/policy-reporter
# helm repo add external-secrets https://charts.external-secrets.io

cd ./argocd
helm dependency build
helm upgrade --install --create-namespace --values=values.yaml -n argocd argocd .
cd -


# Needed by kyverno policy-checker
# helm install external-secrets external-secrets/external-secrets -n external-secrets --create-namespace

kubectl wait deployment -n argocd argocd-server --for condition=Available=True --timeout=90s
kubectl wait deployment -n argocd argocd-applicationset-controller --for condition=Available=True --timeout=90s
kubectl wait deployment -n argocd argocd-notifications-controller --for condition=Available=True --timeout=90s
kubectl wait deployment -n argocd argocd-redis --for condition=Available=True --timeout=90s
kubectl wait deployment -n argocd argocd-repo-server --for condition=Available=True --timeout=90s

kubectl apply -n argocd -f argocd-resources/

