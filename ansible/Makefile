# Makefile for GitLab Ansible Role

# Variables
ANSIBLE_PLAYBOOK := ansible-playbook
INVENTORY := inventory
ROLE_DIR := roles/gitlab
PLAYBOOKS := examples/site.yml examples/site_with_monitoring_and_backups.yml
CERTS_DIR := certs
GITLAB_VERSION ?= 16.0.0
GITLAB_PACKAGE ?= gitlab-ee

.PHONY: help install configure deploy backup restore clean-certs generate-certs letsencrypt-certs test lint

help:
	@echo "Available targets:"
	@echo "  install       - Install GitLab"
	@echo "  configure     - Configure GitLab"
	@echo "  deploy        - Full deployment (install + configure)"
	@echo "  backup        - Configure backups"
	@echo "  restore       - Restore from backup (set GITLAB_RESTORE_BACKUP_NAME)"
	@echo "  clean-certs   - Remove generated certificates"
	@echo "  generate-certs - Generate self-signed certificates"
	@echo "  letsencrypt-certs - Generate Let's Encrypt certificates (set DOMAIN)"
	@echo "  test          - Run playbook in check mode"
	@echo "  lint          - Lint Ansible files"

install:
	$(ANSIBLE_PLAYBOOK) -i $(INVENTORY) examples/site.yml \
		-e "gitlab_version=$(GITLAB_VERSION)" \
		-e "gitlab_package_name=$(GITLAB_PACKAGE)"

configure:
	$(ANSIBLE_PLAYBOOK) -i $(INVENTORY) examples/site_with_monitoring_and_backups.yml \
		-e "gitlab_version=$(GITLAB_VERSION)" \
		-e "gitlab_package_name=$(GITLAB_PACKAGE)"

deploy: install configure

backup:
	$(ANSIBLE_PLAYBOOK) -i $(INVENTORY) examples/site_with_monitoring_and_backups.yml \
		-e "gitlab_backup_enabled=true" \
		-e "gitlab_version=$(GITLAB_VERSION)" \
		-e "gitlab_package_name=$(GITLAB_PACKAGE)"

restore:
	$(ANSIBLE_PLAYBOOK) -i $(INVENTORY) examples/site.yml \
		-e "gitlab_restore_backup_name=$(GITLAB_RESTORE_BACKUP_NAME)" \
		-e "gitlab_version=$(GITLAB_VERSION)" \
		-e "gitlab_package_name=$(GITLAB_PACKAGE)"

clean-certs:
	rm -f $(CERTS_DIR)/gitlab.key $(CERTS_DIR)/gitlab.csr $(CERTS_DIR)/gitlab.crt

generate-certs: clean-certs
	mkdir -p $(CERTS_DIR)
	openssl genpkey -algorithm RSA -out $(CERTS_DIR)/gitlab.key
	chmod 600 $(CERTS_DIR)/gitlab.key
	openssl req -new -key $(CERTS_DIR)/gitlab.key -out $(CERTS_DIR)/gitlab.csr
	openssl x509 -req -days 365 -in $(CERTS_DIR)/gitlab.csr -signkey $(CERTS_DIR)/gitlab.key -out $(CERTS_DIR)/gitlab.crt
	@echo "Certificates generated in $(CERTS_DIR)/"

letsencrypt-certs:
ifndef DOMAIN
	$(error DOMAIN is not set. Usage: make letsencrypt-certs DOMAIN=gitlab.example.com)
endif
	sudo certbot certonly --standalone -d $(DOMAIN)
	sudo mkdir -p /etc/gitlab/ssl
	sudo cp /etc/letsencrypt/live/$(DOMAIN)/fullchain.pem /etc/gitlab/ssl/gitlab.crt
	sudo cp /etc/letsencrypt/live/$(DOMAIN)/privkey.pem /etc/gitlab/ssl/gitlab.key
	sudo chmod 600 /etc/gitlab/ssl/gitlab.key
	@echo "Let's Encrypt certificates installed for $(DOMAIN)"

test:
	$(ANSIBLE_PLAYBOOK) -i $(INVENTORY) --check --diff examples/site_with_monitoring_and_backups.yml

lint:
	ansible-lint $(PLAYBOOKS) $(ROLE_DIR)/tasks/*.yml
	yamllint $(PLAYBOOKS) $(ROLE_DIR)/*/*.yml
