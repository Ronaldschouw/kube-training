# Local Setup
Prerequisites:
- Install kubectl
- Install Docker
- Install k3d (k3s)
- Install Helm


# Networking

This repo will use 3 networks:
- 10.248.0.0/16 as Service CIDR (for Kubernetes Services)
- 10.249.0.0/16 as Cluster CIDR (for Kubernetes Pods)
- 10.250.0.0/16 as Node CIDR (for Kubernetes Nodes in Docker)

# GitHub Token Required
Fetch github token from github 

Save the token to `HEAD/argocd/files/.token`

DO NOT CHECK THIS FILE INTO GIT!

# Create a local k3s cluster
```bash
./create.sh
```

# ArgoCD local

```
http://argo-cd.localhost:8080/
```

