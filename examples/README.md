# Deployment Examples

This directory contains pre-configured `.env` templates for different deployment scenarios. Copy the appropriate template to the root directory as `.env` and customize as needed.

## Available Templates

### 1. Corporate Mail Server (`.env.corporate`)

**Best for**: Enterprise environments, large organizations

**Features**:
- Full security stack enabled (DKIM, SPF, DMARC, ClamAV)
- Strict fail2ban settings (3 attempts, 2-hour ban)
- Extended backup retention (30 days)
- Daily log rotation with 30-day retention
- Strict DMARC policy (`reject`)
- Higher resource requirements

**Use this when**:
- Security is paramount
- Compliance requirements exist
- Budget allows for higher resources (4GB+ RAM)
- Professional corporate email needed

**Quick deploy**:
```bash
cp examples/.env.corporate .env
nano .env  # Update domain and organization
sudo ./build.sh
```

---

### 2. Startup/Small Business (`.env.startup`)

**Best for**: Startups, small businesses, cost-conscious deployments

**Features**:
- Balanced security (DKIM, SPF, DMARC)
- ClamAV disabled to save resources
- Standard backup retention (7 days)
- Moderate fail2ban settings (5 attempts, 1-hour ban)
- Works on 2GB RAM servers
- DMARC quarantine policy

**Use this when**:
- Running on budget hosting (2GB RAM)
- Small team (< 50 users)
- Cost optimization needed
- Basic security sufficient

**Quick deploy**:
```bash
cp examples/.env.startup .env
nano .env  # Update domain and organization
sudo ./build.sh
```

---

### 3. Development/Testing (`.env.development`)

**Best for**: Development environments, testing, staging

**Features**:
- Self-signed SSL certificates
- Minimal services (no spam/virus filtering)
- Fixed passwords for easy testing
- Skip DNS prompts
- Short backup retention (3 days)
- Relaxed security settings
- DKIM disabled

**Use this when**:
- Testing mail server configuration
- Developing email features
- Internal testing only
- Learning mail server setup
- No production traffic

**Quick deploy**:
```bash
cp examples/.env.development .env
# Edit if needed, but works with defaults for local testing
sudo ./build.sh
```

**⚠️ WARNING**: Never use development config in production!

---

## Comparison Matrix

| Feature | Corporate | Startup | Development |
|---------|-----------|---------|-------------|
| **Min RAM** | 4GB | 2GB | 1.5GB |
| **ClamAV** | ✅ Enabled | ❌ Disabled | ❌ Disabled |
| **SpamAssassin** | ✅ Enabled | ✅ Enabled | ❌ Disabled |
| **DKIM** | ✅ Enabled | ✅ Enabled | ❌ Disabled |
| **SSL Cert** | Let's Encrypt | Let's Encrypt | Self-signed |
| **Backup Retention** | 30 days | 7 days | 3 days |
| **DMARC Policy** | reject | quarantine | none |
| **Fail2ban Retries** | 3 | 5 | 10 |
| **Ban Time** | 2 hours | 1 hour | 10 minutes |
| **Log Retention** | 30 days | 8 weeks | 3 days |
| **Best For** | Enterprise | Small Business | Testing |

## Customization Guide

After copying a template, customize these essential fields:

### Required Changes

```bash
# Organization
ORG_NAME="Your Company Name"
ORG_TAGLINE="Your Tagline"

# Domain
PRIMARY_DOMAIN="yourdomain.com"
MAIL_DOMAIN="mail.yourdomain.com"

# Contact
ADMIN_EMAIL="admin@yourdomain.com"
POSTMASTER_EMAIL="postmaster@yourdomain.com"
```

### Optional Changes

```bash
# Branding colors
BRAND_PRIMARY="#your-hex-color"
BRAND_SECONDARY="#your-hex-color"
BRAND_DARK="#your-hex-color"

# Backup settings
BACKUP_RETENTION_DAYS="14"
BACKUP_CRON_SCHEDULE="0 2 * * *"

# Security settings
FAIL2BAN_MAXRETRY="4"
FAIL2BAN_BANTIME="1800"
```

## Multi-Domain Deployment

To deploy multiple mail servers for different domains:

### Option 1: Separate Servers

```bash
# Server 1 - domain-a.com
cp examples/.env.startup .env
nano .env  # Set PRIMARY_DOMAIN="domain-a.com"
sudo ./build.sh

# Server 2 - domain-b.com
cp examples/.env.startup .env
nano .env  # Set PRIMARY_DOMAIN="domain-b.com"
sudo ./build.sh
```

### Option 2: Virtual Domains on Same Server

After initial deployment, add additional domains via Modoboa web interface:
1. Login to Modoboa
2. Navigate to **Domains** → **Add Domain**
3. Configure DNS for the new domain
4. Add mailboxes

## Validation Checklist

After deploying with any template:

- [ ] Web interface accessible: `https://mail.yourdomain.com`
- [ ] Can login with admin credentials
- [ ] DNS records configured correctly
- [ ] DKIM configured (if enabled)
- [ ] Test email send/receive
- [ ] Check spam score at [mail-tester.com](https://www.mail-tester.com/)
- [ ] Verify backups are running: `ls -la $BACKUP_DIR`
- [ ] Review firewall rules: `sudo ufw status`
- [ ] Check service health: `systemctl status postfix dovecot`

## Troubleshooting by Template

### Corporate Template

**High memory usage?**
- This is expected with ClamAV enabled
- Ensure server has 4GB+ RAM
- Monitor with: `free -m`

**Strict security blocking legitimate mail?**
- Review DMARC reports
- Consider changing `DMARC_POLICY="quarantine"`
- Adjust `FAIL2BAN_MAXRETRY` if needed

### Startup Template

**Need antivirus?**
- Enable ClamAV: `CLAMAV_ENABLED="true"`
- Upgrade server to 4GB RAM
- Re-run: `sudo ./build.sh`

**Want longer backup retention?**
- Change `BACKUP_RETENTION_DAYS="14"`
- Ensure sufficient disk space

### Development Template

**Self-signed cert warnings?**
- This is expected in dev
- Add exception in browser
- Or use Let's Encrypt: `CERT_TYPE="letsencrypt"`

**Need to test spam filtering?**
- Enable SpamAssassin: `SPAMASSASSIN_ENABLED="true"`
- Re-run installer

## Getting Help

- **Main documentation**: [../README.md](../README.md)
- **Quick start guide**: [../QUICKSTART.md](../QUICKSTART.md)
- **Full config reference**: [../.env.example](../.env.example)

---

**Need a custom configuration?** Start with the template closest to your needs and customize variables in [.env.example](../.env.example).
