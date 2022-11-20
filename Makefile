SECRET_KEY = SOPS_AGE_KEY_FILE=.age_secret_key

.PHONY: help
.DEFAULT_GOAL := help

help: ## show this message
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

lint: ## check helm syntax
	helm lint .

template: ## print preprocessed templates
	${SECRET_KEY} helm secrets template -f secrets.enc.yaml .

edit_secrets: ## edit encrypted secrets
	${SECRET_KEY} helm secrets edit secrets.enc.yaml

encrypt: ## encrypt secrets.dec.yaml > secrets.enc.yaml
	helm secrets encrypt secrets.dec.yaml > secrets.enc.yaml
	rm -f secrets.dec.yaml

decrypt: ## decrypt secrets.enc.yaml (do not commit secrets.dec.yaml!)
	${SECRET_KEY} helm secrets decrypt secrets.enc.yaml > secrets.dec.yaml

fluent_install:
	helm install fluentd fluent/fluentd -n fluent -f fluentd.values.yaml --create-namespace
fluent_upgrade:
	helm upgrade fluentd fluent/fluentd -n fluent -f fluentd.values.yaml --create-namespace
fluent_uninstall:
	helm uninstall fluentd -n fluent

ingress_install:
	helm install ingress-nginx ingress-nginx/ingress-nginx -n ingress -f ingress-nginx.values.yaml --create-namespace
ingress_upgrade:
	helm upgrade ingress-nginx ingress-nginx/ingress-nginx -n ingress -f ingress-nginx.values.yaml --create-namespace
ingress_uninstall:
	helm uninstall ingress-nginx -n ingress

install: ## install chart
	${SECRET_KEY} helm secrets $@ api-app . -f secrets.enc.yaml --values values.yaml
upgrade: ## upgrade chart
	${SECRET_KEY} helm secrets $@ api-app . -f secrets.enc.yaml --values values.yaml
uninstall: ## uninstall chart
	helm $@ api-app
