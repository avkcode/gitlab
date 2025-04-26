# Ansible Role: GitLab

This role installs and configures GitLab on supported Linux distributions.

## Requirements
- A compatible Linux distribution (e.g., Debian, Ubuntu, CentOS)

## Example Playbook
```yaml
- hosts: gitlab_servers
  roles:
    - role: gitlab
      vars:
        gitlab_tls_enabled: true
        gitlab_tls_cert_file: "gitlab.crt"
        gitlab_tls_key_file: "gitlab.key"
