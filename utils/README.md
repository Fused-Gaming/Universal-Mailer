# Utility Scripts

This directory contains helper scripts for managing and testing your mail server deployment.

## Available Scripts

### validate-config.sh
**Purpose**: Validate `.env` configuration file before deployment

**Usage**:
```bash
./utils/validate-config.sh           # Validates .env
./utils/validate-config.sh .env.test # Validates specific file
```

**Checks**:
- Required variables present
- Email format validation
- Domain format validation
- Color code validation (hex)

### check-dns.sh
**Purpose**: Verify DNS records are configured correctly

**Usage**:
```bash
./utils/check-dns.sh
```

**Checks**:
- A record for mail domain
- MX record for primary domain
- SPF record
- DMARC record
- DKIM record (if configured)

### test-mail.sh
**Purpose**: Test mail server health and functionality

**Usage**:
```bash
sudo ./utils/test-mail.sh
```

**Tests**:
- Service status (Postfix, Dovecot, Nginx, PostgreSQL)
- Port availability (25, 587, 993, 443)
- Mail queue status
- Disk space usage
- Log files

## Planned Utilities

### backup-restore.sh (Coming Soon)
Restore mail server from backup

### domain-add.sh (Coming Soon)
Add additional domain to existing mail server

### health-monitor.sh (Coming Soon)
Continuous health monitoring with alerts

### cert-renew.sh (Coming Soon)
Manual SSL certificate renewal

## Contributing

To add a new utility script:

1. Create script in `utils/` directory
2. Make it executable: `chmod +x utils/yourscript.sh`
3. Add header comment block with purpose and usage
4. Update this README
5. Add tests to CI pipeline

## Requirements

Most scripts require:
- Bash 4.0+
- Standard Unix utilities (grep, awk, sed)
- dig or host (for DNS checks)
- mailq (for mail queue checks)

## Examples

**Complete pre-deployment check**:
```bash
# 1. Validate configuration
./utils/validate-config.sh

# 2. Check DNS
./utils/check-dns.sh

# 3. (After deployment) Test mail server
sudo ./utils/test-mail.sh
```

**Automated validation in CI**:
```yaml
# In GitHub Actions
- name: Validate configuration
  run: ./utils/validate-config.sh .env.example
```

## Troubleshooting

**Script not executable**:
```bash
chmod +x utils/*.sh
```

**DNS check fails**:
- Ensure DNS records are configured
- Wait for DNS propagation (up to 48 hours)
- Check with: `dig mail.yourdomain.com`

**Test failures**:
- Check service logs: `journalctl -u postfix`
- Verify installation completed: `tail -f /var/log/mail-server-install.log`

---

**Note**: These are helper scripts. The main deployment script is `build.sh` in the root directory.
