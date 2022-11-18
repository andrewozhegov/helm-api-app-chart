.PHONY: help
.DEFAULT_GOAL := help

help: ## show this message
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

lint: ## check helm syntax
	helm lint .

template: ## print preprocessed templates
	helm template .

