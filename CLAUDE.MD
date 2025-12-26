# Claude AI Context - Universal Mail Server Template

> This file provides context and guidelines for AI assistants (like Claude) working with this codebase.

## Project Overview

**Name**: Universal Mail Server Deployment Template
**Version**: 0.0.0 (Initial Development)
**Type**: Bash deployment automation for Modoboa mail servers
**Purpose**: Rapidly deploy production-ready mail servers for any domain

### What This Project Does

This is a **fully parameterized deployment template** that automates the installation and configuration of a complete mail server stack (Modoboa, Postfix, Dovecot, OpenDKIM, SpamAssassin, ClamAV) on Ubuntu/Debian servers.

**Key Features:**
- 70+ configurable environment variables
- Pre-built templates for different use cases
- Complete DNS, SSL, security configuration
- Automated backups and monitoring
- Multi-domain deployment capability

## Project Structure

```
mail-vlngg/
├── build.sh                  # Main deployment script (800+ lines)
├── .env.example              # Configuration reference (70+ variables)
├── .env                      # User configuration (git-ignored)
├── examples/                 # Pre-built deployment templates
│   ├── .env.corporate        # Enterprise configuration
│   ├── .env.startup          # Small business configuration
│   └── .env.development      # Development/testing configuration
├── docs/                     # Documentation (auto-generated)
├── utils/                    # Utility scripts
├── .github/workflows/        # CI/CD automation
└── [documentation files]
```

## Key Files

### Critical Files (Never Break These)

1. **build.sh** - Main deployment script
   - Contains all installation logic
   - Loads environment variables from `.env`
   - Must remain POSIX-compliant bash
   - All hardcoded values replaced with `$VARIABLES`

2. **.env.example** - Configuration template
   - Complete reference for all 70+ variables
   - Heavily commented for user guidance
   - Used as fallback if `.env` missing

3. **examples/*.env.*** - Deployment templates
   - Pre-configured for specific use cases
   - Users copy these to `.env` and customize
   - Must remain valid and tested

### Important Conventions

**Environment Variables:**
- ALL_CAPS with underscores: `PRIMARY_DOMAIN`, `MAIL_DOMAIN`
- Defaults provided using: `${VAR:-default_value}`
- Never hardcode values in build.sh - always use variables

**File Paths:**
- Absolute paths preferred over relative
- Use variables: `$INSTALL_DIR`, `$INSTANCE_DIR`, `$BACKUP_DIR`
- Never hardcode paths like `/opt/modoboa`

**Domain References:**
- `PRIMARY_DOMAIN` - Main domain (e.g., `example.com`)
- `MAIL_DOMAIN` - Mail subdomain (e.g., `mail.example.com`)
- Never use hardcoded `vln.gg` or any specific domain

## Development Guidelines

### When Modifying build.sh

1. **Preserve Environment Loading Logic** (lines 15-150)
   - Never break the `.env` loading mechanism
   - Maintain fallback to `.env.example`
   - Keep user prompts for missing config

2. **Use Variable Substitution**
   ```bash
   # ✅ CORRECT
   hostname "$MAIL_DOMAIN"
   mkdir -p "$INSTALL_DIR"

   # ❌ WRONG
   hostname "mail.vln.gg"
   mkdir -p /opt/modoboa
   ```

3. **Maintain Function Structure**
   - Keep functions small and focused
   - Use descriptive names
   - Add log messages: `log`, `log_success`, `log_error`

4. **Test with Multiple Configurations**
   - Test with all three example templates
   - Verify variable substitution works
   - Check generated config files

### When Adding New Features

1. **Add to .env.example first**
   ```bash
   # NEW_FEATURE="default_value"  # Description
   ```

2. **Add to build.sh with default**
   ```bash
   NEW_FEATURE="${NEW_FEATURE:-default_value}"
   ```

3. **Update documentation**
   - README.md
   - CHANGELOG.md
   - Example templates if applicable

4. **Update relevant templates**
   - Corporate, Startup, or Development configs

### Code Quality Standards

**Shell Script Best Practices:**
- Use `set -e` for error handling
- Quote all variables: `"$VARIABLE"`
- Use `[[` for conditionals instead of `[`
- Validate input before using
- Provide clear error messages

**Security Considerations:**
- Never log passwords
- Use `openssl rand` for password generation
- Validate user input
- Check file permissions
- Use HTTPS/SSL by default

## Common Tasks

### Adding a New Configuration Variable

```bash
# 1. Add to .env.example with documentation
NEW_VAR="default"  # Description of what this does

# 2. Add to build.sh configuration section
NEW_VAR="${NEW_VAR:-default}"

# 3. Use in build.sh
echo "Using value: $NEW_VAR"

# 4. Document in README.md if user-facing
```

### Modifying Service Configuration

```bash
# Always use environment variables
cat > config.cfg << EOF
[service]
enabled = $SERVICE_ENABLED
port = $SERVICE_PORT
host = $SERVICE_HOST
EOF
```

### Adding New Deployment Template

```bash
# 1. Create examples/.env.newtemplate
# 2. Copy .env.example structure
# 3. Customize for specific use case
# 4. Document in examples/README.md
# 5. Test deployment with new template
```

## Testing Guidelines

### Before Committing Changes

1. **Syntax Check**
   ```bash
   bash -n build.sh
   shellcheck build.sh
   ```

2. **Variable Validation**
   ```bash
   # Ensure all variables have defaults or are loaded from .env
   grep -E '\$[A-Z_]+' build.sh | grep -v ':-'
   ```

3. **Test with Templates**
   ```bash
   cp examples/.env.development .env
   sudo ./build.sh  # In VM/test environment
   ```

4. **Check Generated Files**
   ```bash
   # Verify no hardcoded values in generated configs
   cat $INSTALL_DIR/installer.cfg
   cat $BACKUP_SCRIPT
   ```

### CI/CD Integration

- All PRs run shellcheck
- Configuration files validated
- Markdown linting
- Security scanning with Trivy
- Documentation link checking

## Documentation Standards

### README.md Updates

- Keep installation steps simple
- Provide working examples
- Include troubleshooting section
- Link to detailed docs

### Code Comments

```bash
# Good: Explains WHY
# Generate secure password if not provided by user
if [ -z "$DB_PASSWORD" ]; then
    DB_PASSWORD=$(openssl rand -base64 32)
fi

# Bad: Explains WHAT (obvious from code)
# Check if password is empty
```

### Commit Messages

Format: `type(scope): description`

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `refactor`: Code refactoring
- `test`: Add/update tests
- `chore`: Maintenance

Examples:
```
feat(config): add DATABASE_POOL_SIZE variable
fix(build): correct DKIM path generation
docs(readme): update quick start guide
refactor(backup): extract backup logic to function
```

## Troubleshooting Common Issues

### Environment Variables Not Loading

```bash
# Check .env file exists and is readable
ls -la .env

# Check for syntax errors in .env
bash -n .env

# Verify variables are exported
source .env && env | grep PRIMARY_DOMAIN
```

### Build Script Failures

```bash
# Check logs
tail -f /var/log/mail-server-install.log

# Verify prerequisites
bash -n build.sh
shellcheck build.sh

# Test in clean environment
docker run -it ubuntu:22.04 bash
```

### Generated Configuration Issues

```bash
# Check if variables are substituted
cat $INSTALL_DIR/installer.cfg | grep '\$'

# Should return nothing - all $ vars should be replaced
```

## Version Management

Current version: **0.0.0** (pre-release development)

### Versioning Scheme

Following Semantic Versioning (semver):
- MAJOR.MINOR.PATCH (e.g., 1.2.3)
- MAJOR: Breaking changes
- MINOR: New features (backward compatible)
- PATCH: Bug fixes

### Release Process

1. Update VERSION file
2. Update CHANGELOG.md
3. Update version in build.sh: `SCRIPT_VERSION`
4. Create git tag: `git tag -a v1.0.0 -m "Release 1.0.0"`
5. Push tag: `git push origin v1.0.0`
6. GitHub Actions handles release automation

## AI Assistant Guidelines

### When Asked to Modify Code

1. **Always check existing patterns first**
   - Look at how similar features are implemented
   - Match existing code style
   - Use same variable naming conventions

2. **Preserve backward compatibility**
   - Don't break existing .env files
   - Provide defaults for new variables
   - Document migration if needed

3. **Update all related files**
   - build.sh
   - .env.example
   - Example templates
   - README.md
   - CHANGELOG.md

4. **Test conceptually**
   - Trace variable flow
   - Check for undefined variables
   - Verify error handling

### When Asked to Add Features

1. **Start with user requirements**
   - What problem does this solve?
   - Is it configurable or hardcoded?
   - Does it fit the project scope?

2. **Design before coding**
   - What variables are needed?
   - Which templates should include it?
   - What are the defaults?
   - What can go wrong?

3. **Implement systematically**
   - Add to .env.example (with docs)
   - Add to build.sh (with defaults)
   - Update relevant functions
   - Add to example templates
   - Document in README.md

4. **Provide testing guidance**
   - How to test the feature
   - What to check for
   - Common issues

### When Asked Questions

1. **Check documentation first**
   - README.md for user-facing info
   - build.sh comments for implementation
   - .env.example for configuration options

2. **Provide practical examples**
   - Show actual .env values
   - Demonstrate with realistic domains
   - Include troubleshooting steps

3. **Reference existing patterns**
   - Point to similar implementations
   - Show how other features work
   - Explain the reasoning

## Project Goals

### Primary Goals

1. ✅ **Universal Deployment**: Works for any domain with simple config changes
2. ✅ **Production Ready**: Secure, tested, documented
3. ✅ **Easy to Use**: Copy template, edit 4 variables, deploy
4. ✅ **Well Documented**: Multiple docs for different audiences
5. ⚠️ **Actively Maintained**: Regular updates, bug fixes (in progress)

### Non-Goals

- ❌ Not a web-based control panel (use Modoboa for that)
- ❌ Not a mail client
- ❌ Not for Windows servers
- ❌ Not a managed service

## Quick Reference

### Key Variables

```bash
# Essential
PRIMARY_DOMAIN="example.com"
MAIL_DOMAIN="mail.example.com"
ADMIN_EMAIL="admin@example.com"
ORG_NAME="Your Organization"

# Branding
BRAND_PRIMARY="#0066FF"
BRAND_SECONDARY="#00D4FF"
BRAND_DARK="#0A0E27"

# Services (true/false)
DOVECOT_ENABLED="true"
POSTFIX_ENABLED="true"
OPENDKIM_ENABLED="true"
CLAMAV_ENABLED="true"
```

### Important Paths

```bash
INSTALL_DIR="/opt/modoboa"
INSTANCE_DIR="/srv/modoboa/instance"
BACKUP_DIR="/var/backups/mail-server"
LOG_FILE="/var/log/mail-server-install.log"
```

### Main Functions (build.sh)

```bash
show_banner()          # Display startup banner
preflight_checks()     # Validate system requirements
configure_hostname()   # Set server hostname
check_dns()           # Verify DNS configuration
install_modoboa()     # Install Modoboa
configure_modoboa()   # Generate Modoboa config
apply_vln_branding()  # Apply custom branding
harden_security()     # Configure firewall & fail2ban
post_install()        # Setup backups & logging
generate_report()     # Create installation report
```

## Support & Resources

- **Main Documentation**: [README.md](README.md)
- **Quick Start**: [QUICKSTART.md](QUICKSTART.md)
- **Configuration**: [.env.example](.env.example)
- **Examples**: [examples/](examples/)
- **Issues**: GitHub Issues
- **Modoboa Docs**: https://modoboa.readthedocs.io/

---

**Last Updated**: 2025-01-26
**For AI Assistants**: This file helps you understand the codebase quickly. Always preserve the core functionality: environment variable loading, template system, and multi-domain support.
