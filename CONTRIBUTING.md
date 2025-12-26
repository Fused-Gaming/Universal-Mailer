# Contributing to Universal Mail Server Template

Thank you for your interest in contributing! We welcome contributions from the community.

## Quick Links

- Report bugs: [GitHub Issues](https://github.com/Fused-Gaming/Universal-Mailer/issues)
- Request features: [GitHub Discussions](https://github.com/Fused-Gaming/Universal-Mailer/discussions)
- Security issues: See [SECURITY.md](SECURITY.md)

## How to Contribute

### Reporting Bugs

Include:
- OS version and mail server template version
- Steps to reproduce
- Expected vs actual behavior
- Log files (redact sensitive info)

### Suggesting Features

Before suggesting:
1. Check if it already exists
2. Search existing feature requests
3. Consider if it fits project scope

### Pull Requests

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Test thoroughly (see Testing section)
5. Commit: `git commit -m 'feat: add amazing feature'`
6. Push: `git push origin feature/amazing-feature`
7. Open Pull Request

## Development Guidelines

### Code Style

```bash
# Use environment variables, not hardcoded values
# ✅ CORRECT
hostname "$MAIL_DOMAIN"

# ❌ WRONG
hostname "mail.example.com"

# Always quote variables
if [[ "$PRIMARY_DOMAIN" == "example.com" ]]; then
    echo "Domain: $PRIMARY_DOMAIN"
fi

# Use proper error handling
if ! some_command; then
    log_error "Command failed"
    exit 1
fi
```

### Commit Messages

Format: `type(scope): description`

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `refactor`: Code refactoring
- `test`: Tests
- `chore`: Maintenance

Examples:
```
feat(backup): add S3 backup support
fix(dns): correct DKIM path generation
docs(readme): update installation steps
```

### Testing

Before submitting PR:

```bash
# 1. Lint shell scripts
shellcheck build.sh

# 2. Check syntax
bash -n build.sh

# 3. Test with example templates
cp examples/.env.development .env
sudo ./build.sh  # In test environment

# 4. Verify no hardcoded values
grep -r "vln.gg" build.sh  # Should return nothing
```

### Documentation

Update when:
- Adding features → README.md, QUICKSTART.md
- Changing config → .env.example
- Bug fixes → CHANGELOG.md
- Breaking changes → Migration guide

## Pull Request Checklist

- [ ] Code follows project style
- [ ] Tested with all three example templates
- [ ] No hardcoded values introduced
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Shellcheck passes
- [ ] Commit messages follow convention

## Questions?

- Open a GitHub Discussion
- Check existing documentation
- Review closed issues

Thank you for contributing!
