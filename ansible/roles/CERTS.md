
If you do not have access to a trusted CA, you can generate self-signed certificates. These are suitable for testing but not recommended for production environments.

Create a Private Key  Run the following command to generate a private key (gitlab.key):
```
openssl genpkey -algorithm RSA -out gitlab.key
chmod 600 gitlab.key  # Restrict permissions for security
```

Generate a Certificate Signing Request (CSR)  Use the private key to create a CSR (gitlab.csr):
```
openssl req -new -key gitlab.key -out gitlab.csr
```

Generate a Self-Signed Certificate  Use the CSR to generate a self-signed certificate (gitlab.crt) valid for 365 days:
```
openssl x509 -req -days 365 -in gitlab.csr -signkey gitlab.key -out gitlab.crt
```

Verify the Certificate  Ensure the certificate and key match:
```
openssl x509 -noout -modulus -in gitlab.crt | openssl md5
openssl rsa -noout -modulus -in gitlab.key | openssl md5
```

### Obtain Certificates from Let's Encrypt

For production environments, use a trusted CA like Let's Encrypt to generate free TLS certificates.

Install Certbot  Install Certbot and the appropriate plugin for your web server:
```
sudo apt update && sudo apt install certbot python3-certbot-nginx  # For Nginx
sudo apt install certbot python3-certbot-apache                  # For Apache
```

Obtain a Certificate  Run Certbot to obtain a certificate for your domain:
```
sudo certbot certonly --standalone -d gitlab.example.com
```

Certbot will:
- Verify domain ownership.
- Generate the certificate and private key.

By default, Certbot stores the files in /etc/letsencrypt/live/gitlab.example.com/.

Locate the Files  After successful issuance, the files will be located in:
- Certificate: /etc/letsencrypt/live/gitlab.example.com/fullchain.pem
- Private Key: /etc/letsencrypt/live/gitlab.example.com/privkey.pem

Copy the files to your desired location (e.g., /etc/gitlab/ssl/):
```
sudo mkdir -p /etc/gitlab/ssl
sudo cp /etc/letsencrypt/live/gitlab.example.com/fullchain.pem /etc/gitlab/ssl/gitlab.crt
sudo cp /etc/letsencrypt/live/gitlab.example.com/privkey.pem /etc/gitlab/ssl/gitlab.key
sudo chmod 600 /etc/gitlab/ssl/gitlab.key
```

### Configure GitLab with TLS Certificates

Once the certificates are generated or obtained, configure GitLab to use them.
In your Ansible playbook, specify the paths to the certificate and key:
```
gitlab_tls_enabled: true
gitlab_tls_cert_file: "gitlab.crt"
gitlab_tls_key_file: "gitlab.key"
gitlab_tls_src_files: "/etc/gitlab/ssl"
```

GitLab Configuration Template

Ensure your gitlab.rb.j2 template includes the TLS settings:
```
external_url 'https://{{ ansible_fqdn }}'

# Enable TLS
nginx['ssl_certificate'] = "{{ gitlab_config_path }}/ssl/{{ gitlab_tls_cert_file }}"
nginx['ssl_certificate_key'] = "{{ gitlab_config_path }}/ssl/{{ gitlab_tls_key_file }}"
```

Test the Configuration

After applying the configuration:
```
sudo gitlab-ctl reconfigure
sudo gitlab-ctl restart
```

Verify TLS:
- Open a browser and navigate to https://gitlab.example.com.
- Check that the connection is secure and the certificate is valid.

Use OpenSSL to test the connection:
```
openssl s_client -connect gitlab.example.com:443 -servername gitlab.example.com
```
### Automate Certificate Renewal (Let's Encrypt Only)

Let's Encrypt certificates are valid for 90 days. Automate renewal to avoid expiration:

Add a cron job for automatic renewal:
```
sudo crontab -e
```

Add the following line:
```
0 2 * * * certbot renew --quiet --renew-hook "gitlab-ctl reconfigure"
```

Test the renewal process manually:
```
sudo certbot renew --dry-run
```
