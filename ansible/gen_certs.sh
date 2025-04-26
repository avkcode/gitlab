#!/bin/bash

set -e

DOMAIN="${1:-your-gitlab-domain.com}"
CERTS_DIR="certs"
GITLAB_SSL_DIR="roles/gitlab/files/tls"

echo "Generating certificates for $DOMAIN..."
mkdir -p "$CERTS_DIR"

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$CERTS_DIR/gitlab.key" \
    -out "$CERTS_DIR/gitlab.crt" \
    -subj "/CN=$DOMAIN/O=GitLab"

echo "Deploying to $GITLAB_SSL_DIR..."
sudo mkdir -p "$GITLAB_SSL_DIR"
sudo cp "$CERTS_DIR/gitlab.key" "$GITLAB_SSL_DIR/"
sudo cp "$CERTS_DIR/gitlab.crt" "$GITLAB_SSL_DIR/"
sudo chown git:git "$GITLAB_SSL_DIR/gitlab.key" "$GITLAB_SSL_DIR/gitlab.crt"
sudo chmod 600 "$GITLAB_SSL_DIR/gitlab.key"
sudo chmod 644 "$GITLAB_SSL_DIR/gitlab.crt"

echo "Certificates generated and deployed successfully"
