DISTRO ?= ubuntu2404

# CentOS Stream 9 has no maintained systemd test image, so it is built locally.
ifeq ($(DISTRO),centos9)
IMAGE ?= localhost/molecule-centos9:latest
IMAGE_DEP := image
else
IMAGE ?= docker.io/geerlingguy/docker-$(DISTRO)-ansible:latest
IMAGE_DEP :=
endif

export MOLECULE_DISTRO := $(DISTRO)
export MOLECULE_IMAGE := $(IMAGE)

.PHONY: help deps lint syntax image test converge verify destroy run check

help: ## Show this help
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

deps: ## Install Python tooling and Ansible collections
	pip install -r requirements-dev.txt
	ansible-galaxy collection install -r requirements.yml
	ansible-galaxy collection install community.docker

lint: ## Run yamllint and ansible-lint
	yamllint .
	ansible-lint

syntax: ## Syntax-check every playbook
	@for p in site.yml playbooks/*.yml; do ansible-playbook --syntax-check $$p || exit 1; done

image: ## Build the CentOS Stream 9 test image
	docker build -t localhost/molecule-centos9:latest -f molecule/images/centos9.Dockerfile molecule/images

test: $(IMAGE_DEP) ## Full Molecule test on DISTRO (default ubuntu2404)
	molecule test

converge: $(IMAGE_DEP) ## Converge a Molecule container and keep it running
	molecule converge

verify: ## Run the Molecule verifier against the running container
	molecule verify

destroy: ## Remove the Molecule container
	molecule destroy

check: ## Dry run against the inventory with diff
	ansible-playbook site.yml --check --diff

run: ## Apply site.yml to the inventory
	ansible-playbook site.yml
