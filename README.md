# Universal Mail Server Deployment Stack

A fully parameterized, production-ready mail server deployment template based on Modoboa. Deploy secure, scalable mail servers for any domain in minutes.

## 🚀 Features

- **🔧 Fully Configurable**: All domain-specific values are externalized to environment variables
- **📦 Complete Mail Stack**: Postfix, Dovecot, OpenDKIM, SpamAssassin, ClamAV, Amavis
- **🎨 Custom Branding**: Configurable colors, organization name, and styling
- **🔒 Security Hardened**: UFW firewall, Fail2ban, automated backups
- **📊 Web Interface**: Modoboa admin panel for easy management
- **🔐 SSL/TLS**: Let's Encrypt integration for automatic certificates
- **💾 Automated Backups**: Configurable retention and scheduling
- **📝 Comprehensive Logging**: Centralized logs with rotation

## 📋 System Requirements

- **OS**: Ubuntu 20.04/22.04 or Debian 11/12
- **RAM**: Minimum 2GB (4GB recommended)
- **Disk**: Minimum 10GB (20GB recommended)
- **Network**: Static IP address with reverse DNS (PTR record)
- **Root Access**: Required for installation

## 🎯 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/Fused-Gaming/Universal-Mailer.git
cd mail-server-template
```

### 2. Configure Your Environment

```bash
# Copy the example environment file
cp .env.example .env

# Edit with your domain and preferences
nano .env
```

### 3. Configure DNS Records

**Before running the installer**, ensure these DNS records are configured:

```
# A Record
mail.yourdomain.com → YOUR_SERVER_IP

# MX Record
yourdomain.com → mail.yourdomain.com (Priority: 10)

# PTR Record (Reverse DNS)
YOUR_SERVER_IP → mail.yourdomain.com

# SPF Record
yourdomain.com → TXT "v=spf1 mx ~all"

# DMARC Record
_dmarc.yourdomain.com → TXT "v=DMARC1; p=quarantine; rua=mailto:postmaster@yourdomain.com"
```

### 4. Run the Installer

```bash
# Make the script executable
chmod +x build.sh

# Run as root
sudo ./build.sh
```

Installation typically takes 15-30 minutes depending on your server.

## ⚙️ Configuration Guide

### Essential Configuration Variables

Edit your [.env](.env) file with these **required** values:

```bash
# Your organization name
ORG_NAME="ACME Corporation"

# Your tagline/description
ORG_TAGLINE="Secure Email Solutions"

# Primary domain
PRIMARY_DOMAIN="example.com"

# Mail server subdomain
MAIL_DOMAIN="mail.example.com"

# Admin email (for Let's Encrypt and notifications)
ADMIN_EMAIL="admin@example.com"
```

### Branding Configuration

Customize the look and feel:

```bash
# Brand colors (hex format with #)
BRAND_PRIMARY="#0066FF"
BRAND_SECONDARY="#00D4FF"
BRAND_DARK="#0A0E27"
```

### Service Configuration

Enable or disable mail services:

```bash
DOVECOT_ENABLED="true"        # IMAP/POP3
POSTFIX_ENABLED="true"        # SMTP
OPENDKIM_ENABLED="true"       # Email authentication
AMAVIS_ENABLED="true"         # Content filter
SPAMASSASSIN_ENABLED="true"   # Spam filtering
CLAMAV_ENABLED="true"         # Antivirus
RADICALE_ENABLED="false"      # Calendar/Contacts
```

### Port Configuration

Customize service ports if needed:

```bash
PORT_SMTP="25"          # Standard SMTP
PORT_SUBMISSION="587"   # SMTP with STARTTLS
PORT_SMTPS="465"        # SMTP over SSL
PORT_IMAPS="993"        # IMAP over SSL
PORT_POP3S="995"        # POP3 over SSL
```

### Backup Configuration

Configure automated backups:

```bash
BACKUP_DIR="/var/backups/mail-server"
BACKUP_RETENTION_DAYS="7"
BACKUP_CRON_SCHEDULE="0 2 * * *"  # Daily at 2 AM
```

## 📖 Complete Configuration Reference

See [.env.example](.env.example) for all available configuration options with detailed descriptions.

## 🔐 Post-Installation

### 1. Access the Web Interface

```
https://mail.yourdomain.com
```

Login with the credentials shown in the installation report:
```
Username: admin
Password: [shown in terminal and saved to /root/yourdomain.com-MAIL-INFO.txt]
```

### 2. Configure DKIM

After installation, add your DKIM public key to DNS:

```bash
# View your DKIM public key
sudo cat /etc/opendkim/keys/yourdomain.com/mail.txt
```

Add as TXT record:
```
mail._domainkey.yourdomain.com → [contents of mail.txt]
```

### 3. Create Email Accounts

1. Login to Modoboa web interface
2. Navigate to **Domains** → **yourdomain.com**
3. Click **Mailboxes** → **Add Mailbox**
4. Configure user accounts

### 4. Test Email Delivery

Use [mail-tester.com](https://www.mail-tester.com/) to verify:
- SPF configuration
- DKIM signing
- DMARC policy
- Spam score
- Blacklist status

## 🛠️ Management

### Useful Commands

```bash
# Check mail queue
mailq

# View real-time mail logs
tail -f /var/log/mail.log

# Restart mail services
systemctl restart postfix dovecot

# Run manual backup
/usr/local/bin/mail-server-backup.sh

# Check service status
systemctl status postfix dovecot nginx postgresql

# Test DKIM configuration
opendkim-testkey -d yourdomain.com -s mail -vvv
```

### Backup Management

Backups are stored in `$BACKUP_DIR` (default: `/var/backups/mail-server/`)

**Backup contents:**
- PostgreSQL database dump
- Mail data (`/var/mail`)
- Configuration files (Postfix, Dovecot, Modoboa)

**Restore from backup:**

```bash
# Restore database
sudo -u postgres psql modoboa < /var/backups/mail-server/modoboa_db_YYYYMMDD_HHMMSS.sql

# Restore mail data
tar -xzf /var/backups/mail-server/mail_data_YYYYMMDD_HHMMSS.tar.gz -C /

# Restore configuration
tar -xzf /var/backups/mail-server/config_YYYYMMDD_HHMMSS.tar.gz -C /
```

## 🔒 Security

### Firewall (UFW)

The installer configures UFW with the following rules:
- SSH (port 22)
- HTTP (port 80) - for Let's Encrypt
- HTTPS (port 443) - web interface
- SMTP (port 25)
- Submission (port 587)
- SMTPS (port 465)
- IMAPS (port 993)
- POP3S (port 995)

### Fail2ban

Automatic IP banning after failed login attempts:
- Max retries: 5 (configurable via `FAIL2BAN_MAXRETRY`)
- Ban time: 1 hour (configurable via `FAIL2BAN_BANTIME`)

### SSL/TLS Certificates

Let's Encrypt certificates are automatically generated and renewed. Certificates are stored in:
```
/etc/letsencrypt/live/yourdomain.com/
```

## 🚢 Deployment Examples

### Example 1: Simple Single Domain

```bash
# .env
ORG_NAME="My Company"
PRIMARY_DOMAIN="mycompany.com"
MAIL_DOMAIN="mail.mycompany.com"
ADMIN_EMAIL="admin@mycompany.com"
```

### Example 2: Multi-Brand Setup

Deploy separate mail servers for different brands:

```bash
# Brand A (.env)
ORG_NAME="Brand A Solutions"
PRIMARY_DOMAIN="brand-a.com"
MAIL_DOMAIN="mail.brand-a.com"
BRAND_PRIMARY="#FF6B6B"

# Brand B (.env)
ORG_NAME="Brand B Technologies"
PRIMARY_DOMAIN="brand-b.com"
MAIL_DOMAIN="mail.brand-b.com"
BRAND_PRIMARY="#4ECDC4"
```

### Example 3: Development/Staging Environment

```bash
# .env
ORG_NAME="Company Dev Mail"
PRIMARY_DOMAIN="dev-mail.company.com"
MAIL_DOMAIN="mail.dev-mail.company.com"
CERT_TYPE="selfsigned"  # Use self-signed cert for dev
BACKUP_RETENTION_DAYS="3"  # Shorter retention for dev
```

## 📊 Monitoring

### Log Files

```bash
# Installation log
/var/log/mail-server-install.log

# Mail logs
/var/log/mail.log
/var/log/mail.err
/var/log/mail.warn

# Service logs
journalctl -u postfix
journalctl -u dovecot
journalctl -u nginx
```

### Health Checks

```bash
# Check if services are running
systemctl status postfix dovecot nginx postgresql amavis clamav-daemon opendkim

# Check SMTP connectivity
telnet mail.yourdomain.com 25

# Check IMAP connectivity
openssl s_client -connect mail.yourdomain.com:993
```

## 🐛 Troubleshooting

### Email Not Sending

1. Check Postfix status: `systemctl status postfix`
2. View mail queue: `mailq`
3. Check logs: `tail -f /var/log/mail.log`
4. Verify DNS records: `dig mail.yourdomain.com`
5. Test SMTP: `telnet mail.yourdomain.com 25`

### Email Going to Spam

1. Verify SPF record: `dig TXT yourdomain.com`
2. Test DKIM: `opendkim-testkey -d yourdomain.com -s mail -vvv`
3. Check DMARC: `dig TXT _dmarc.yourdomain.com`
4. Test deliverability: [mail-tester.com](https://www.mail-tester.com/)
5. Check blacklists: [mxtoolbox.com](https://mxtoolbox.com/blacklists.aspx)

### Can't Login to Web Interface

1. Check Nginx status: `systemctl status nginx`
2. Verify certificate: `certbot certificates`
3. Check Modoboa logs: `journalctl -u modoboa`
4. Reset admin password: See [Modoboa docs](https://modoboa.readthedocs.io/)

### High Memory Usage

1. Disable ClamAV if not needed: `CLAMAV_ENABLED="false"`
2. Tune SpamAssassin: Reduce scanning load
3. Increase server RAM to 4GB minimum
4. Check for memory leaks: `free -m` and `top`

## 🔄 Updates & Maintenance

### Update Modoboa

```bash
cd /opt/modoboa
source venv/bin/activate
pip install --upgrade modoboa modoboa-installer
```

### Update System Packages

```bash
apt update && apt upgrade -y
```

### Renew SSL Certificates

Certificates auto-renew via cron. Manual renewal:

```bash
certbot renew
systemctl reload nginx
```

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with multiple domain configurations
5. Submit a pull request

## 📄 License

See [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: [Modoboa Docs](https://modoboa.readthedocs.io/)
- **Issues**: [GitHub Issues](https://github.com/Fused-Gaming/Universal-Mailer/issues)
- **Email**: support@yourorganization.com

## 🙏 Acknowledgments

- [Modoboa](https://modoboa.org/) - Mail server management platform
- [Postfix](http://www.postfix.org/) - SMTP server
- [Dovecot](https://www.dovecot.org/) - IMAP/POP3 server
- [Let's Encrypt](https://letsencrypt.org/) - Free SSL certificates

## 📝 Version History

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

---

**Built with ❤️ for easy mail server deployments**
