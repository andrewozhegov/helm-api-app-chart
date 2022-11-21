# Helm chart for api-app

```
minikube start --driver=podman --kubernetes-version='1.24.0'
git clone https://github.com/andrewozhegov/helm-api-app-chart
cd helm-api-app-chart
make install
```

## Tasks

* ECR

To pull images from private ECR, specify it's credentials in secrets

```
make edit_secrets
```

Then specify appropriate image names in `values.yaml` and use images Release version as `AppVersion` in `Chart.yaml`

```
images:
  app:
    repo: nginx         # specify api image here
    tag: latest         # delete this to use .Chart.AppVersion as tag
    pullPolicy: Always
  init:
    repo: busybox       # specify alembic image here
    tag: 1.28           # delete this to use .Chart.AppVersion as tag
    pullPolicy: Always
```

* Use `config` section in `values.yaml` to configure api & alembic

Vars will pass to containers as ENV vars from ConfigMaps

```
config:
  app:
    SOME_VAR: some_val
  init:
    ANOTHER_VAR: another_val
```

* Container & initContainer

As `alembic` supposed to run migrations before app will work with DB it present as `initContaider`
Both containers uses `db` secret to get database credentials as ENV vars

* Provide external access to API

API deployment exposed as `LoadBalancer` on HTTP port, with `Ingress` resource

```
make ingress_install    # will deploys nginx-ingress-controller
minikube tunnel         # supposed to find and expose right service himself
```

This approach supposed to work properly with cloud providers too!

* Split API logs

For `api` stdout logs parsing I use `fluend`. To configure it, make changes in `fluentd.values.yaml` file.
Use `<match kubernetes.var.log.containers.api-app**>` section in `fileConfigs.02_filters.conf` to configure REGEX to determine **sensitive** logs from usual:

```
02_filters.conf: |-
 . . .
   <match kubernetes.var.log.containers.api-app**>
 . . .
    <rule>
      key log                               # JSON key of Value to parse
      pattern ^.*GET\s\/sensitive.*$        # REGEX to match sensitive log
      tag api-app-log.sensitive
    </rule>
    <rule>
      key log                               # JSON key of Value to parse
      pattern ^(.+)$                        # REGEX to match all usual rest of logs
      tag api-app-log.std
    </rule>
  </match>
```

Use `<label @API_APP>` section in `fileConfigs.04_outputs.conf` to configure any [fluend output plugin](https://docs.fluentd.org/output) for each of the log tag!

```
04_outputs.conf: |-
  <label @API_APP>
    <match api-app-log.sensitive>
      @type stdout
    </match>
    <match api-app-log.std>
      @type stdout
    </match>
  </label>
```

When configuration is done, deploy `fluentd`

```
make fluentd_install
make fluentd_upgrade   # to upd conf of already deployed fluentd
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
