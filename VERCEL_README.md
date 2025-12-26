# ⚠️ This Repository is Not for Vercel Deployment

This repository contains a **mail server deployment script** designed to run on Ubuntu/Debian servers.

## Why This Won't Work on Vercel

- ✗ Requires root access to install system packages
- ✗ Needs to configure Postfix, Dovecot, PostgreSQL
- ✗ Must bind to ports 25, 587, 993, etc.
- ✗ Requires persistent storage for mail data
- ✗ Needs to modify system configuration files

## What This Repository Does

**Universal Mail Server Template** - Automated deployment of production mail servers:
- Complete Modoboa mail stack
- DKIM, SPF, DMARC configuration
- SSL/TLS with Let's Encrypt
- Spam filtering and antivirus
- Web-based management interface

## How to Use This Template

### On a Mail Server (Ubuntu/Debian):

```bash
# 1. Clone the repository
git clone https://github.com/Fused-Gaming/Universal-Mailer.git
cd Universal-Mailer

# 2. Configure for your domain
cp .env.example .env
nano .env  # Edit PRIMARY_DOMAIN, MAIL_DOMAIN, etc.

# 3. Run deployment script
sudo ./build.sh
```

### For Documentation Only

If you want to host documentation on Vercel:
1. Fork this repository
2. Create a `docs/` folder with your static site
3. Configure Vercel to build from `docs/`
4. Remove `build.sh` from Vercel build commands

## Repository Links

- **Public Template**: https://github.com/Fused-Gaming/Universal-Mailer
- **Documentation**: See [README.md](README.md)
- **Quick Start**: See [QUICKSTART.md](QUICKSTART.md)

## Need Help?

This is a server deployment tool. For questions:
- Read [README.md](README.md) for full documentation
- Check [QUICKSTART.md](QUICKSTART.md) for deployment guide
- Open an issue on GitHub

---

**TL;DR**: This repository deploys mail servers on VPS/dedicated servers, not on Vercel.
