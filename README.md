# Helm chart for api-app

```
minikube start --driver=podman --kubernetes-version='1.24.0'
git clone https://github.com/andrewozhegov/helm-api-app-chart
cd helm-api-app-chart
make install
```

## Requirements

```
# ⚠️ Kubernetes <= v1.24.x
# cause k8s 1.25+ policy/v1beta1 PodSecurityPolicy is deprecated
# but fluentd chart isn't updated yet

brew install helm sops age minikube

helm repo add fluent https://fluent.github.io/helm-charts
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

helm plugin install https://github.com/jkroepke/helm-secrets
```

## Secrets

⚠️ Of course, in a real repo `.age_secret_key` must be securely hidden!

### How to encrypt/decrypt secrets

* edit secrets without manual decryption

```
make edit_secrets
```

* manually decrypt `secrets.enc.yaml` into `secrets.dec.yaml`, edit it and encrypt again

```
make encrypt
vim secrets.dec.yaml
make decrypt
```
