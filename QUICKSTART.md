# Quick Start Guide

Get your mail server running in 5 steps.

## Prerequisites Checklist

- [ ] Fresh Ubuntu 20.04/22.04 or Debian 11/12 server
- [ ] Minimum 2GB RAM, 10GB disk
- [ ] Static IP address
- [ ] Root/sudo access
- [ ] Domain name ready

## Step 1: Prepare DNS (5 minutes)

Before installation, configure these DNS records:

```
Type    Name                            Value                           TTL
────────────────────────────────────────────────────────────────────────────
A       mail.yourdomain.com             YOUR_SERVER_IP                  3600
MX      yourdomain.com                  mail.yourdomain.com (10)        3600
TXT     yourdomain.com                  v=spf1 mx ~all                  3600
TXT     _dmarc.yourdomain.com           v=DMARC1; p=quarantine; ...     3600
```

**Important**: Also configure **PTR (Reverse DNS)** with your hosting provider:
```
YOUR_SERVER_IP → mail.yourdomain.com
```

Wait 5-10 minutes for DNS propagation, then verify:

```bash
dig mail.yourdomain.com
dig MX yourdomain.com
```

## Step 2: Download & Configure (2 minutes)

```bash
# Clone repository
git clone https://github.com/Fused-Gaming/Universal-Mailer.git
cd mail-server-template

# Copy environment template
cp .env.example .env

# Edit configuration
nano .env
```

**Minimum required changes in `.env`:**

```bash
ORG_NAME="Your Company Name"
PRIMARY_DOMAIN="yourdomain.com"
MAIL_DOMAIN="mail.yourdomain.com"
ADMIN_EMAIL="admin@yourdomain.com"
```

Save and exit (`Ctrl+O`, `Enter`, `Ctrl+X`)

## Step 3: Run Installation (20-30 minutes)

```bash
# Make executable
chmod +x build.sh

# Run as root
sudo ./build.sh
```

The script will:
1. ✓ Verify system requirements
2. ✓ Install all dependencies
3. ✓ Configure mail services
4. ✓ Setup SSL certificates
5. ✓ Configure firewall
6. ✓ Setup automated backups

**⚠️ SAVE THE PASSWORDS** displayed at the end!

## Step 4: Configure DKIM (5 minutes)

After installation completes, get your DKIM public key:

```bash
sudo cat /etc/opendkim/keys/yourdomain.com/mail.txt
```

Add as DNS TXT record:

```
Name: mail._domainkey.yourdomain.com
Type: TXT
Value: [paste the entire content from mail.txt]
TTL: 3600
```

Verify DKIM after 5 minutes:

```bash
opendkim-testkey -d yourdomain.com -s mail -vvv
```

## Step 5: Create Email Accounts (5 minutes)

1. **Access web interface**: https://mail.yourdomain.com
2. **Login** with credentials from installation report
3. **Navigate to**: Domains → yourdomain.com → Mailboxes
4. **Click**: "Add Mailbox"
5. **Create** your first email account

## Verification Checklist

Test your mail server setup:

- [ ] Can access https://mail.yourdomain.com
- [ ] Can login to admin panel
- [ ] DKIM test passes: `opendkim-testkey -d yourdomain.com -s mail -vvv`
- [ ] Services running: `systemctl status postfix dovecot nginx`
- [ ] Send test email to external address
- [ ] Receive test email from external address
- [ ] Check spam score: [mail-tester.com](https://www.mail-tester.com/)
- [ ] Verify DNS: [mxtoolbox.com](https://mxtoolbox.com/SuperTool.aspx)

## Next Steps

- [ ] **Change admin password** in web interface
- [ ] **Configure email clients** (Thunderbird, Outlook, etc.)
- [ ] **Setup monitoring** (optional)
- [ ] **Configure mobile devices** (optional)
- [ ] **Review security settings**

## Common Issues & Quick Fixes

### Can't access web interface

```bash
# Check Nginx status
sudo systemctl status nginx

# Check certificate
sudo certbot certificates

# Restart Nginx
sudo systemctl restart nginx
```

### Emails going to spam

1. Verify SPF: `dig TXT yourdomain.com`
2. Verify DKIM: `opendkim-testkey -d yourdomain.com -s mail -vvv`
3. Verify DMARC: `dig TXT _dmarc.yourdomain.com`
4. Test at: [mail-tester.com](https://www.mail-tester.com/)

### Can't send/receive email

```bash
# Check Postfix
sudo systemctl status postfix

# Check Dovecot
sudo systemctl status dovecot

# View logs
sudo tail -f /var/log/mail.log

# Check mail queue
mailq
```

## Email Client Configuration

### IMAP (Incoming Mail)
- **Server**: mail.yourdomain.com
- **Port**: 993
- **Security**: SSL/TLS
- **Username**: yourname@yourdomain.com
- **Password**: [your mailbox password]

### SMTP (Outgoing Mail)
- **Server**: mail.yourdomain.com
- **Port**: 587
- **Security**: STARTTLS
- **Username**: yourname@yourdomain.com
- **Password**: [your mailbox password]

## Getting Help

- **Full documentation**: [README.md](README.md)
- **Configuration reference**: [.env.example](.env.example)
- **Logs**: `/var/log/mail-server-install.log`
- **Installation info**: `/root/yourdomain.com-MAIL-INFO.txt`

---

**Total setup time: ~45 minutes** (including DNS propagation)
