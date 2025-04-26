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

# Monitoring with Prometheus and Grafana

Enable Prometheus metrics by setting:
```yaml
gitlab_prometheus_enabled: true
gitlab_grafana_enabled: true

## Vars

The `gitlab_backup_enabled` variable determines whether backups are enabled. Here’s how to control it:
Disable Backups : Set `gitlab_backup_enabled: false` in the playbook or inventory.
Enable Backups : Set `gitlab_backup_enabled: true`.

You can also override this variable at runtime using the --extra-vars flag:
```bash
ansible-playbook -i inventory site.yml --extra-vars "gitlab_backup_enabled=true"
```

The `gitlab_prometheus_enabled` and `gitlab_grafana_enabled` variables control whether Prometheus and Grafana are configured.

Disable Monitoring : Set both `gitlab_prometheus_enabled: false` and `gitlab_grafana_enabled: false`.
Enable Monitoring : Set `gitlab_prometheus_enabled: true` and optionally `gitlab_grafana_enabled: true`.

Override these variables at runtime:
```bash
ansible-playbook -i inventory site.yml --extra-vars "gitlab_prometheus_enabled=true gitlab_grafana_enabled=true"
```
