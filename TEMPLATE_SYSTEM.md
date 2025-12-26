# Mail Server Template System - Transformation Summary

## Overview

This repository has been transformed from a single-domain, hardcoded mail server deployment script into a **universal, fully parameterized template system** that can rapidly deploy mail servers for any domain.

## What Changed

### Before (Hardcoded)
- Domain: `vln.gg` hardcoded throughout
- Organization: `VLN - Fused Gaming` hardcoded
- Colors: VLN brand colors hardcoded
- Paths, ports, settings all hardcoded
- Single-use deployment script

### After (Parameterized Template)
- **All values** externalized to environment variables
- **Universal deployment** for any domain/organization
- **Pre-built templates** for different use cases
- **Fully documented** with examples
- **Production-ready** multi-domain deployment system

## File Structure

```
mail-vlngg/
├── .env.example              # Complete configuration reference (70+ variables)
├── .env                      # Your custom configuration (git-ignored)
├── build.sh                  # Refactored deployment script (100% parameterized)
├── README.md                 # Comprehensive documentation
├── QUICKSTART.md             # 5-step quick start guide
├── TEMPLATE_SYSTEM.md        # This file
├── examples/
│   ├── README.md             # Examples documentation
│   ├── .env.corporate        # Enterprise configuration
│   ├── .env.startup          # Small business configuration
│   └── .env.development      # Development/testing configuration
└── [other files unchanged]
```

## Key Features

### 1. Complete Parameterization (70+ Variables)

Every aspect is configurable via `.env`:

**Organization & Branding**
- Organization name and tagline
- Brand colors (primary, secondary, dark)
- Custom styling

**Domain Configuration**
- Primary domain
- Mail subdomain
- Admin and postmaster emails

**Service Configuration**
- Enable/disable each mail service
- Database settings
- SSL/TLS configuration
- Port customization

**Security & Backup**
- Firewall rules
- Fail2ban settings
- Backup retention and scheduling
- Log rotation

### 2. Smart Environment Loading

The refactored [build.sh](build.sh) includes:

```bash
# Automatic .env detection
if [ -f "$SCRIPT_DIR/.env" ]; then
    source "$SCRIPT_DIR/.env"
else
    # Prompts user or falls back to .env.example
fi

# All variables with defaults
ORG_NAME="${ORG_NAME:-VLN - Fused Gaming}"
PRIMARY_DOMAIN="${PRIMARY_DOMAIN:-vln.gg}"
# ... 70+ more variables
```

### 3. Pre-Built Deployment Templates

Three ready-to-use configurations in `examples/`:

| Template | Best For | Key Features |
|----------|----------|--------------|
| **Corporate** | Enterprise | Full security, 30-day backups, strict policies |
| **Startup** | Small business | Balanced features, cost-optimized, 2GB RAM |
| **Development** | Testing | Self-signed certs, minimal services, relaxed security |

### 4. Comprehensive Documentation

- **README.md**: Full documentation (400+ lines)
- **QUICKSTART.md**: Get running in 45 minutes
- **examples/README.md**: Template comparison and guidance
- **.env.example**: Inline documentation for every variable

## How to Use

### Rapid Deployment (3 Commands)

```bash
# 1. Copy appropriate template
cp examples/.env.startup .env

# 2. Customize domain
nano .env  # Change PRIMARY_DOMAIN, MAIL_DOMAIN, etc.

# 3. Deploy
sudo ./build.sh
```

### Multi-Domain Deployment

Deploy different mail servers by simply changing `.env`:

```bash
# Deploy for client A
cp examples/.env.corporate .env
# Edit for client-a.com
sudo ./build.sh

# Deploy for client B
cp examples/.env.startup .env
# Edit for client-b.com
sudo ./build.sh
```

## Technical Improvements

### Script Enhancements

1. **Environment Variable Loading**
   - Automatic `.env` detection
   - Fallback to `.env.example`
   - User prompts for missing config
   - All variables with sensible defaults

2. **Dynamic Configuration Generation**
   - Modoboa config generated from env vars
   - Backup scripts with parameterized paths
   - DNS instructions with actual domain values
   - Installation reports with custom branding

3. **Improved Logging**
   - Log file path configurable
   - Named by domain for multi-deployment
   - Installation info file per domain

4. **Better Error Handling**
   - Validates .env existence
   - Checks required variables
   - Clear error messages

### Backward Compatibility

The VLN defaults are preserved in `.env.example`, so running without configuration still works:

```bash
# Still works with VLN defaults
sudo ./build.sh
```

## Configuration Variables Reference

### Essential Variables (Required)
```bash
ORG_NAME="Your Organization"
PRIMARY_DOMAIN="yourdomain.com"
MAIL_DOMAIN="mail.yourdomain.com"
ADMIN_EMAIL="admin@yourdomain.com"
```

### Branding Variables
```bash
BRAND_PRIMARY="#0066FF"
BRAND_SECONDARY="#00D4FF"
BRAND_DARK="#0A0E27"
ORG_TAGLINE="Your Tagline"
```

### Service Toggles
```bash
DOVECOT_ENABLED="true"
POSTFIX_ENABLED="true"
OPENDKIM_ENABLED="true"
SPAMASSASSIN_ENABLED="true"
CLAMAV_ENABLED="true"
```

### Security Settings
```bash
FAIL2BAN_MAXRETRY="5"
FAIL2BAN_BANTIME="3600"
MX_PRIORITY="10"
SPF_RECORD="v=spf1 mx ~all"
DMARC_POLICY="quarantine"
```

See [.env.example](.env.example) for complete reference (70+ variables).

## Examples of Use

### Example 1: Deploy for ACME Corp

```bash
cp examples/.env.corporate .env
```

Edit `.env`:
```bash
ORG_NAME="ACME Corporation"
PRIMARY_DOMAIN="acmecorp.com"
MAIL_DOMAIN="mail.acmecorp.com"
ADMIN_EMAIL="it@acmecorp.com"
```

Deploy:
```bash
sudo ./build.sh
```

Result: Fully branded mail server at `https://mail.acmecorp.com`

### Example 2: Testing Environment

```bash
cp examples/.env.development .env
sudo ./build.sh  # Uses defaults, self-signed cert, minimal services
```

### Example 3: Multi-Brand Agency

Deploy mail servers for multiple clients:

```bash
# Client 1
cp examples/.env.startup .env
nano .env  # Set to client1.com
sudo ./build.sh

# Client 2
cp examples/.env.startup .env
nano .env  # Set to client2.com
sudo ./build.sh
```

## Migration from Old Version

If you have the old hardcoded version:

1. **Backup existing installation**
2. **Pull latest changes**: `git pull`
3. **Create `.env`**: `cp .env.example .env`
4. **Set your domain**: Edit `.env` with your actual domain
5. **Re-run if needed**: `sudo ./build.sh`

The script will detect existing configuration and prompt appropriately.

## Testing the Template System

### Test 1: Validate Script Syntax

```bash
bash -n build.sh  # Check for syntax errors
```

### Test 2: Dry-Run Environment Loading

```bash
# Create test .env
cat > .env << EOF
PRIMARY_DOMAIN="test.local"
MAIL_DOMAIN="mail.test.local"
ORG_NAME="Test Org"
EOF

# Source and verify
source .env
echo $PRIMARY_DOMAIN  # Should show: test.local
```

### Test 3: Deploy in Development

```bash
cp examples/.env.development .env
sudo ./build.sh
```

## Benefits of This System

### For Developers
- ✅ Copy/paste deployment for new domains
- ✅ Version control friendly (`.env` is git-ignored)
- ✅ Easy testing with dev template
- ✅ Clear configuration management

### For Organizations
- ✅ Rapid multi-domain deployment
- ✅ Consistent configuration across servers
- ✅ Easy branding per domain
- ✅ Template-based best practices

### For Agencies/MSPs
- ✅ Deploy for multiple clients quickly
- ✅ Maintain separate configurations per client
- ✅ Standardized deployment process
- ✅ Easy to document and train

## Future Enhancements

Potential additions:
- [ ] Ansible playbook integration
- [ ] Docker containerization option
- [ ] Multi-domain on single server automation
- [ ] Configuration validation script
- [ ] Terraform module
- [ ] Automated DNS verification via API
- [ ] Backup to S3/cloud storage
- [ ] Monitoring integration (Prometheus/Grafana)

## Support & Contribution

- **Issues**: Report bugs or request features
- **Pull Requests**: Contributions welcome
- **Documentation**: Help improve docs
- **Templates**: Share your `.env` templates

## Credits

**Original Script**: VLN mail server deployment
**Refactored to Template System**: 2025
**Transformation**: Complete parameterization, documentation, examples

---

## Summary of Changes

| Aspect | Before | After |
|--------|--------|-------|
| **Configurability** | Hardcoded | 70+ env variables |
| **Domains** | Single (vln.gg) | Universal (any domain) |
| **Templates** | None | 3 pre-built configs |
| **Documentation** | None | 4 comprehensive guides |
| **Reusability** | Single-use | Multi-domain template |
| **Files Changed** | N/A | build.sh, .env.example, docs |
| **Lines of Config** | 0 | 400+ in .env.example |
| **Deployment Time** | Same | Same (45 min) |
| **Learning Curve** | Moderate | Easy (with templates) |

---

**This template system transforms a single-purpose script into a production-ready, multi-domain mail server deployment platform.**
