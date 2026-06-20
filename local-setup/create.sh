#!/bin/bash
set -e
k3d cluster create --config cluster.yaml

sleep 5

#kubectl wait deployment -n kube-system traefik --for condition=Available=True --timeout=90s
kubectl wait deployment -n kube-system metrics-server --for condition=Available=True --timeout=90s
kubectl wait deployment -n kube-system coredns --for condition=Available=True --timeout=90s
kubectl wait deployment -n kube-system local-path-provisioner --for condition=Available=True --timeout=90s

# Install Ingress Nginx
# ./install-nginx.sh

# Install ArgoCD
# ./install-argocd.sh

