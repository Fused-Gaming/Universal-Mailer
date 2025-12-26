# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Docker containerization support
- Ansible playbook integration
- Automated DNS API integration
- Multi-domain single-server automation
- Monitoring integration (Prometheus/Grafana)
- S3/cloud backup support

## [0.0.0] - 2025-01-26

### Added - Initial Release

#### Template System
- Complete parameterization of mail server deployment
- 70+ configurable environment variables via `.env`
- Smart environment loading with fallback to `.env.example`
- Automatic password generation for security

#### Pre-Built Templates
- **Corporate template** - Enterprise configuration with full security
- **Startup template** - Cost-optimized for small businesses
- **Development template** - Testing environment with self-signed certs

#### Core Features
- Automated Modoboa installation and configuration
- Complete mail stack (Postfix, Dovecot, OpenDKIM, SpamAssassin, ClamAV)
- SSL/TLS with Let's Encrypt integration
- UFW firewall configuration
- Fail2ban security
- Automated daily backups with configurable retention
- Log rotation
- Custom branding and theming

#### Documentation
- Comprehensive README.md (400+ lines)
- Quick start guide (QUICKSTART.md)
- Template system documentation (TEMPLATE_SYSTEM.md)
- Configuration examples for 3 different use cases
- Inline documentation in `.env.example`
- CLAUDE.MD for AI assistant context

#### CI/CD
- GitHub Actions workflows for CI
- Shellcheck linting
- Configuration validation
- Security scanning with Trivy
- Documentation generation
- Release automation

#### Project Structure
- MIT License
- Contributing guidelines
- Security policy
- Code of conduct
- Configuration schema (JSON)
- Documentation index (docs.json)

### Changed
- **[BREAKING]** Replaced all hardcoded `vln.gg` references with environment variables
- **[BREAKING]** Changed default version from `1.0.0` to `0.0.0` for initial development
- Renamed log file from `/var/log/vln-modoboa-install.log` to `/var/log/mail-server-install.log`
- Updated backup script naming to be domain-agnostic
- Modified output file names to include `PRIMARY_DOMAIN`

### Migration from Previous Version
If upgrading from the hardcoded version:

```bash
# 1. Backup existing installation
cp build.sh build.sh.backup

# 2. Pull latest changes
git pull

# 3. Create .env file
cp .env.example .env

# 4. Configure for your domain
nano .env
# Set PRIMARY_DOMAIN, MAIL_DOMAIN, ORG_NAME, etc.

# 5. Test configuration
bash -n build.sh

# 6. Deploy (in test environment first)
sudo ./build.sh
```

### Dependencies
- Ubuntu 20.04/22.04 or Debian 11/12
- Bash 4.0+
- OpenSSL (for password generation)
- Python 3 (for Modoboa)
- PostgreSQL (installed automatically)

### Removed
- Hardcoded domain references (`vln.gg`, `mail.vln.gg`)
- Hardcoded organization name (`VLN - Fused Gaming`)
- Hardcoded brand colors
- Fixed paths and settings

## Version History Summary

| Version | Date | Type | Description |
|---------|------|------|-------------|
| 0.0.0 | 2025-01-26 | Initial | Template system created from hardcoded script |

## Upgrade Path

### From Hardcoded Version → 0.0.0
1. Create `.env` file with your configuration
2. Run updated `build.sh`
3. Verify all services operational
4. Test email send/receive

## Security Advisories

None yet. See [SECURITY.md](SECURITY.md) for reporting procedures.

## Contributors

Thank you to all contributors! See CONTRIBUTORS file.

---

**Note**: For detailed information about each version, see the git tags and release notes on GitHub.

[Unreleased]: https://github.com/Fused-Gaming/Universal-Mailer/compare/v0.0.0...HEAD
[0.0.0]: https://github.com/Fused-Gaming/Universal-Mailer/releases/tag/v0.0.0
