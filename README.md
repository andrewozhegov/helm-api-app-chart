# Helm chart for api-app

## Secrets

### Requirements

```
brew install sops age
helm plugin install https://github.com/jkroepke/helm-secrets
```

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
