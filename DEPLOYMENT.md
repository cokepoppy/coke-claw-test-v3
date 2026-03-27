# Kubernetes Deployment Guide

## Project Overview

Coke Claw Login Demo - A full-stack application with:
- **Frontend**: React + Vite login page (static, no API calls)
- **Backend**: Spring Boot 3.3.5 + Java 21 REST API
- **Deployment Target**: Kubernetes cluster

---

## Architecture

```
                    ┌─────────────────────────────────────┐
                    │           Ingress (nginx)            │
                    │   coke-claw-test-v3.claw.*          │
                    └─────────────────┬───────────────────┘
                                      │
                    ┌─────────────────┴───────────────────┐
                    │                                     │
          ┌─────────▼─────────┐               ┌──────────▼──────────┐
          │   Frontend SVC    │               │    Backend SVC      │
          │   Port: 80        │               │    Port: 8080       │
          └─────────┬─────────┘               └──────────┬──────────┘
                    │                                     │
          ┌─────────▼─────────┐               ┌──────────▼──────────┐
          │  Frontend Pod     │               │   Backend Pod       │
          │  nginx:alpine     │               │  java:21-jre        │
          │  React build      │               │  Spring Boot        │
          └───────────────────┘               └─────────────────────┘
```

---

## Configuration Files

| File | Purpose |
|------|---------|
| `deploy/app.yaml` | App metadata and deployment config |
| `deploy/frontend.Dockerfile` | Frontend container image build |
| `deploy/backend.Dockerfile` | Backend container image build |
| `deploy/nginx.conf` | Nginx config for SPA routing |
| `deploy/k8s/frontend.yaml` | Frontend deployment + service |
| `deploy/k8s/backend.yaml` | Backend deployment + service |
| `deploy/k8s/ingress.yaml` | Ingress routing rules |
| `.github/workflows/deploy-k8s.yml` | CI/CD pipeline |

---

## Prerequisites

### GitHub Secrets Required

| Secret | Description |
|--------|-------------|
| `REGISTRY_USERNAME` | Container registry username |
| `REGISTRY_PASSWORD` | Container registry password/token |
| `REGISTRY_SERVER` | Registry server (default: ghcr.io) |
| `KUBE_CONFIG_B64` | Base64-encoded kubeconfig file |

---

## Deployment Steps

### Option 1: Automatic via GitHub Actions (Recommended)

1. **Push to the deployment branch:**
   ```bash
   git push origin remote-k8s-e2e-mn8k0lp5-q7ugoc
   ```

2. **Monitor the workflow:**
   - Go to: Actions > Deploy Kubernetes
   - Wait for "build-and-deploy" job completion

### Option 2: Manual Deployment

1. **Build and push images:**
   ```bash
   # Frontend
   docker build -f deploy/frontend.Dockerfile -t <registry>/coke-claw-test-v3-frontend:latest .
   docker push <registry>/coke-claw-test-v3-frontend:latest

   # Backend
   docker build -f deploy/backend.Dockerfile -t <registry>/coke-claw-test-v3-backend:latest .
   docker push <registry>/coke-claw-test-v3-backend:latest
   ```

2. **Update image references in K8s manifests:**
   ```bash
   export FRONTEND_IMAGE_REF="<registry>/coke-claw-test-v3-frontend:latest"
   export BACKEND_IMAGE_REF="<registry>/coke-claw-test-v3-backend:latest"
   ```

3. **Apply manifests:**
   ```bash
   kubectl create namespace claw-shangguan --dry-run=client -o yaml | kubectl apply -f -
   envsubst < deploy/k8s/frontend.yaml | kubectl apply -n claw-shangguan -f -
   envsubst < deploy/k8s/backend.yaml | kubectl apply -n claw-shangguan -f -
   kubectl apply -n claw-shangguan -f deploy/k8s/ingress.yaml
   ```

---

## Access Points

| Service | URL |
|---------|-----|
| Frontend | https://coke-claw-test-v3.claw.coke-twitter.com |
| Backend Health | https://coke-claw-test-v3.claw.coke-twitter.com/api/health |
| Backend Login | https://coke-claw-test-v3.claw.coke-twitter.com/api/login (POST) |

---

## Health & Resource Configuration

### Backend
- **Health Check**: `/api/health`
- **Resources**: 256Mi/100m request, 512Mi/500m limit
- **Liveness Probe**: 30s initial delay, 10s period
- **Readiness Probe**: 10s initial delay, 5s period

### Frontend
- **Health Check**: `/` (root path)
- **Resources**: 64Mi/50m request, 128Mi/200m limit
- **Liveness Probe**: 10s initial delay, 10s period
- **Readiness Probe**: 5s initial delay, 5s period

---

## Application Behavior (Unchanged)

### Frontend
- Static React login page
- No database required
- Form submission is visual only (no backend integration)

### Backend API
- `POST /api/login` - Returns success with username (no auth)
- `GET /api/health` - Health check endpoint
- No database connection required

---

## Troubleshooting

### Check pod status:
```bash
kubectl get pods -n claw-shangguan
kubectl logs -n claw-shangguan deployment/coke-claw-test-v3-frontend
kubectl logs -n claw-shangguan deployment/coke-claw-test-v3-backend
```

### Check services:
```bash
kubectl get svc -n claw-shangguan
kubectl describe ingress coke-claw-test-v3-ingress -n claw-shangguan
```

### Restart deployment:
```bash
kubectl rollout restart deployment/coke-claw-test-v3-frontend -n claw-shangguan
kubectl rollout restart deployment/coke-claw-test-v3-backend -n claw-shangguan
```
