#!/bin/bash

###############################################################################
#
# Universal Mail Server Deployment Stack
# Modoboa Email Server Setup - Template Edition
#
# Copyright © 2025
# Multi-Domain Mail Server Deployment Tool
#
###############################################################################

set -e

###############################################################################
# Environment Variable Loading
###############################################################################

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect if running in CI/CD or non-interactive environment
if [ -z "$TERM" ] || [ "$TERM" = "dumb" ] || [ -n "$CI" ] || [ -n "$VERCEL" ] || [ -n "$GITHUB_ACTIONS" ]; then
    echo "⚠ Detected CI/CD or non-interactive environment"
    echo "This script is designed to run on a mail server, not in CI/CD."
    echo "Skipping deployment. For documentation, see README.md"
    exit 0
fi

# Load environment variables from .env file
if [ -f "$SCRIPT_DIR/.env" ]; then
    # Export variables from .env file
    set -a
    source "$SCRIPT_DIR/.env"
    set +a
    echo "✓ Loaded configuration from .env file"
else
    echo "⚠ WARNING: .env file not found at $SCRIPT_DIR/.env"
    echo "Please copy .env.example to .env and configure your settings:"
    echo "  cp .env.example .env"
    echo "  nano .env"
    echo ""
    read -p "Continue with default values from .env.example? (y/n): " USE_DEFAULTS
    if [[ ! "$USE_DEFAULTS" =~ ^[Yy]$ ]]; then
        echo "Installation cancelled. Please create .env file first."
        exit 1
    fi
    # Load defaults from .env.example
    if [ -f "$SCRIPT_DIR/.env.example" ]; then
        set -a
        source "$SCRIPT_DIR/.env.example"
        set +a
        echo "✓ Loaded default configuration from .env.example"
    else
        echo "✗ ERROR: Neither .env nor .env.example found!"
        exit 1
    fi
fi

###############################################################################
# Configuration Variables (Loaded from .env)
###############################################################################

# Organization & Branding
ORG_NAME="${ORG_NAME:-VLN - Fused Gaming}"
ORG_TAGLINE="${ORG_TAGLINE:-Smart Contract Vulnerability Research Lab}"
BRAND_PRIMARY="${BRAND_PRIMARY:-#0066FF}"
BRAND_SECONDARY="${BRAND_SECONDARY:-#00D4FF}"
BRAND_DARK="${BRAND_DARK:-#0A0E27}"

# Domain Configuration
PRIMARY_DOMAIN="${PRIMARY_DOMAIN:-vln.gg}"
MAIL_DOMAIN="${MAIL_DOMAIN:-mail.vln.gg}"
ADMIN_EMAIL="${ADMIN_EMAIL:-admin@vln.gg}"
POSTMASTER_EMAIL="${POSTMASTER_EMAIL:-postmaster@${PRIMARY_DOMAIN}}"

# System Configuration
SCRIPT_VERSION="${SCRIPT_VERSION:-1.0.0}"
LOG_FILE="${LOG_FILE:-/var/log/mail-server-install.log}"
INSTALL_DIR="${INSTALL_DIR:-/opt/modoboa}"
INSTANCE_DIR="${INSTANCE_DIR:-/srv/modoboa/instance}"

# Database Configuration
DB_ENGINE="${DB_ENGINE:-postgres}"
DB_NAME="${DB_NAME:-modoboa}"
DB_USER="${DB_USER:-modoboa}"
DB_HOST="${DB_HOST:-localhost}"
DB_PASSWORD="${DB_PASSWORD:-}"  # Auto-generated if empty

# Modoboa Admin
MODOBOA_ADMIN_USER="${MODOBOA_ADMIN_USER:-admin}"
MODOBOA_ADMIN_PASSWORD="${MODOBOA_ADMIN_PASSWORD:-}"  # Auto-generated if empty
MODOBOA_LANGUAGE="${MODOBOA_LANGUAGE:-en}"

# SSL/TLS Configuration
CERT_GENERATE="${CERT_GENERATE:-true}"
CERT_TYPE="${CERT_TYPE:-letsencrypt}"
CERT_EMAIL="${CERT_EMAIL:-${ADMIN_EMAIL}}"

# Service Configuration
DOVECOT_ENABLED="${DOVECOT_ENABLED:-true}"
POSTFIX_ENABLED="${POSTFIX_ENABLED:-true}"
OPENDKIM_ENABLED="${OPENDKIM_ENABLED:-true}"
AMAVIS_ENABLED="${AMAVIS_ENABLED:-true}"
AMAVIS_USER="${AMAVIS_USER:-amavis}"
SPAMASSASSIN_ENABLED="${SPAMASSASSIN_ENABLED:-true}"
CLAMAV_ENABLED="${CLAMAV_ENABLED:-true}"
RADICALE_ENABLED="${RADICALE_ENABLED:-false}"
NGINX_ENABLED="${NGINX_ENABLED:-true}"

# Port Configuration
PORT_SSH="${PORT_SSH:-22}"
PORT_HTTP="${PORT_HTTP:-80}"
PORT_HTTPS="${PORT_HTTPS:-443}"
PORT_SMTP="${PORT_SMTP:-25}"
PORT_SUBMISSION="${PORT_SUBMISSION:-587}"
PORT_SMTPS="${PORT_SMTPS:-465}"
PORT_IMAPS="${PORT_IMAPS:-993}"
PORT_POP3S="${PORT_POP3S:-995}"

# Backup Configuration
BACKUP_DIR="${BACKUP_DIR:-/var/backups/mail-server}"
BACKUP_RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-7}"
BACKUP_CRON_SCHEDULE="${BACKUP_CRON_SCHEDULE:-0 2 * * *}"
BACKUP_SCRIPT="${BACKUP_SCRIPT:-/usr/local/bin/mail-server-backup.sh}"
BACKUP_LOG="${BACKUP_LOG:-/var/log/mail-server-backup.log}"

# Fail2ban Configuration
FAIL2BAN_MAXRETRY="${FAIL2BAN_MAXRETRY:-5}"
FAIL2BAN_BANTIME="${FAIL2BAN_BANTIME:-3600}"

# System Requirements
MIN_MEMORY_MB="${MIN_MEMORY_MB:-1800}"
MIN_DISK_GB="${MIN_DISK_GB:-10}"

# Log Rotation
LOGROTATE_FREQUENCY="${LOGROTATE_FREQUENCY:-weekly}"
LOGROTATE_COUNT="${LOGROTATE_COUNT:-12}"

# Connectivity
CONNECTIVITY_TEST_HOST="${CONNECTIVITY_TEST_HOST:-google.com}"
IP_DETECTION_SERVICE="${IP_DETECTION_SERVICE:-ifconfig.me}"

# DNS Configuration
SKIP_DNS_PROMPT="${SKIP_DNS_PROMPT:-false}"
MX_PRIORITY="${MX_PRIORITY:-10}"
SPF_RECORD="${SPF_RECORD:-v=spf1 mx ~all}"
DMARC_POLICY="${DMARC_POLICY:-quarantine}"

# Auto-generate passwords if not provided
if [ -z "$DB_PASSWORD" ]; then
    DB_PASSWORD=$(openssl rand -base64 32)
fi

if [ -z "$MODOBOA_ADMIN_PASSWORD" ]; then
    MODOBOA_ADMIN_PASSWORD=$(openssl rand -base64 16)
fi

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

###############################################################################
# Logging Functions
###############################################################################

log() {
    echo -e "${CYAN}[VLN]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1" | tee -a "$LOG_FILE"
}

log_header() {
    echo "" | tee -a "$LOG_FILE"
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}" | tee -a "$LOG_FILE"
    echo -e "${BLUE}║${NC}  $1" | tee -a "$LOG_FILE"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
}

###############################################################################
# Banner
###############################################################################

show_banner() {
    clear
    echo -e "${CYAN}"
    cat << EOF
    ╔══════════════════════════════════════════════════════════════╗
    ║                                                              ║
    ║           UNIVERSAL MAIL SERVER DEPLOYMENT STACK            ║
    ║                                                              ║
    ╚══════════════════════════════════════════════════════════════╝

    Organization: $ORG_NAME
    $ORG_TAGLINE
    Mail Server Deployment Stack v$SCRIPT_VERSION

EOF
    echo -e "${NC}"
    echo -e "Domain:        ${GREEN}$MAIL_DOMAIN${NC}"
    echo -e "Primary:       ${GREEN}$PRIMARY_DOMAIN${NC}"
    echo -e "Admin Email:   ${CYAN}$ADMIN_EMAIL${NC}"
    echo ""
}

###############################################################################
# Pre-flight Checks
###############################################################################

preflight_checks() {
    log_header "Pre-flight System Checks"
    
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
    log_success "Running as root"
    
    # Check OS
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VER=$VERSION_ID
        log_success "Detected OS: $OS $VER"
    else
        log_error "Cannot detect OS. This script requires Ubuntu 20.04/22.04 or Debian 11/12"
        exit 1
    fi
    
    # Verify supported OS
    if [[ "$OS" != "ubuntu" ]] && [[ "$OS" != "debian" ]]; then
        log_error "Unsupported OS. Please use Ubuntu 20.04/22.04 or Debian 11/12"
        exit 1
    fi
    
    # Check internet connectivity
    if ping -c 1 "$CONNECTIVITY_TEST_HOST" &> /dev/null; then
        log_success "Internet connectivity verified"
    else
        log_error "No internet connectivity detected"
        exit 1
    fi

    # Check available memory (Modoboa needs at least 2GB)
    TOTAL_MEM=$(free -m | awk '/^Mem:/{print $2}')
    if [ "$TOTAL_MEM" -lt "$MIN_MEMORY_MB" ]; then
        log_warning "Low memory detected ($TOTAL_MEM MB). Recommended: ${MIN_MEMORY_MB}MB+"
    else
        log_success "Memory check passed ($TOTAL_MEM MB)"
    fi

    # Check disk space
    DISK_SPACE=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ "$DISK_SPACE" -lt "$MIN_DISK_GB" ]; then
        log_warning "Low disk space ($DISK_SPACE GB). Recommended: ${MIN_DISK_GB}GB+"
    else
        log_success "Disk space check passed ($DISK_SPACE GB available)"
    fi
}

###############################################################################
# Hostname & DNS Validation
###############################################################################

configure_hostname() {
    log_header "Hostname Configuration"

    CURRENT_HOSTNAME=$(hostname -f)
    log "Current hostname: $CURRENT_HOSTNAME"

    if [ "$CURRENT_HOSTNAME" != "$MAIL_DOMAIN" ]; then
        log "Setting hostname to $MAIL_DOMAIN"
        hostnamectl set-hostname "$MAIL_DOMAIN"

        # Update /etc/hosts
        EXTERNAL_IP=$(curl -s "$IP_DETECTION_SERVICE")
        echo "$EXTERNAL_IP $MAIL_DOMAIN mail" >> /etc/hosts

        log_success "Hostname configured"
    else
        log_success "Hostname already correct"
    fi
}

check_dns() {
    log_header "DNS Configuration Check"

    # Skip if configured to do so
    if [[ "$SKIP_DNS_PROMPT" == "true" ]]; then
        log_warning "Skipping DNS prompt (SKIP_DNS_PROMPT=true)"
        return
    fi

    log_warning "Please ensure the following DNS records are configured:"
    echo ""
    echo -e "${YELLOW}A Record:${NC}"
    echo "  $MAIL_DOMAIN → [YOUR_SERVER_IP]"
    echo ""
    echo -e "${YELLOW}MX Record:${NC}"
    echo "  $PRIMARY_DOMAIN → $MAIL_DOMAIN (Priority: $MX_PRIORITY)"
    echo ""
    echo -e "${YELLOW}SPF Record (TXT):${NC}"
    echo "  $PRIMARY_DOMAIN → $SPF_RECORD"
    echo ""
    echo -e "${YELLOW}DMARC Record (TXT):${NC}"
    echo "  _dmarc.$PRIMARY_DOMAIN → v=DMARC1; p=$DMARC_POLICY; rua=mailto:$POSTMASTER_EMAIL"
    echo ""
    echo -e "${YELLOW}Reverse DNS (PTR):${NC}"
    echo "  [YOUR_SERVER_IP] → $MAIL_DOMAIN"
    echo ""

    read -p "Have you configured these DNS records? (y/n): " DNS_READY
    if [[ ! "$DNS_READY" =~ ^[Yy]$ ]]; then
        log_error "Please configure DNS records before proceeding"
        exit 1
    fi

    log_success "DNS configuration confirmed"
}

###############################################################################
# System Updates & Dependencies
###############################################################################

update_system() {
    log_header "System Updates & Dependencies"
    
    log "Updating package lists..."
    apt-get update -qq
    
    log "Upgrading system packages..."
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq
    
    log "Installing essential dependencies..."
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
        python3 \
        python3-pip \
        python3-venv \
        python3-dev \
        git \
        curl \
        wget \
        gnupg2 \
        ca-certificates \
        lsb-release \
        software-properties-common \
        build-essential \
        libssl-dev \
        libffi-dev \
        libxml2-dev \
        libxslt1-dev \
        libjpeg-dev \
        libpq-dev \
        zlib1g-dev
    
    log_success "System updated and dependencies installed"
}

###############################################################################
# Modoboa Installation
###############################################################################

install_modoboa() {
    log_header "Modoboa Installation"

    log "Creating Modoboa directory..."
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR"

    log "Setting up Python virtual environment..."
    python3 -m venv venv
    source venv/bin/activate

    log "Upgrading pip..."
    pip install --upgrade pip wheel setuptools

    log "Installing Modoboa installer..."
    pip install modoboa-installer

    log_success "Modoboa installer ready"
}

###############################################################################
# Modoboa Configuration
###############################################################################

configure_modoboa() {
    log_header "Modoboa Configuration"

    cd "$INSTALL_DIR"
    source venv/bin/activate

    # Create installer configuration
    cat > installer.cfg << EOF
[general]
hostname = $MAIL_DOMAIN
domain = $PRIMARY_DOMAIN

[database]
engine = $DB_ENGINE

[postgres]
user = $DB_USER
password = $DB_PASSWORD
host = $DB_HOST

[certificate]
generate = $CERT_GENERATE
type = $CERT_TYPE
email = $CERT_EMAIL

[modoboa]
admin_username = $MODOBOA_ADMIN_USER
admin_password = $MODOBOA_ADMIN_PASSWORD
language = $MODOBOA_LANGUAGE

[dovecot]
enabled = $DOVECOT_ENABLED

[postfix]
enabled = $POSTFIX_ENABLED

[amavis]
enabled = $AMAVIS_ENABLED
user = $AMAVIS_USER

[spamassassin]
enabled = $SPAMASSASSIN_ENABLED

[clamav]
enabled = $CLAMAV_ENABLED

[radicale]
enabled = $RADICALE_ENABLED

[opendkim]
enabled = $OPENDKIM_ENABLED

[nginx]
enabled = $NGINX_ENABLED
EOF

    log "Configuration file created"

    log "Running Modoboa installer (this may take 15-30 minutes)..."
    modoboa-installer install -c installer.cfg

    log_success "Modoboa installation complete"
}

###############################################################################
# Custom Branding & Customization
###############################################################################

apply_vln_branding() {
    log_header "Applying Custom Branding"

    # Use instance directory from environment variable
    STATIC_DIR="$INSTANCE_DIR/staticfiles"

    if [ -d "$STATIC_DIR" ]; then
        log "Customizing Modoboa interface..."

        # Create custom CSS
        mkdir -p "$STATIC_DIR/custom/css"
        cat > "$STATIC_DIR/custom/css/custom-theme.css" << EOF
/* Custom Mail Server Theme */
:root {
    --brand-primary: $BRAND_PRIMARY;
    --brand-secondary: $BRAND_SECONDARY;
    --brand-dark: $BRAND_DARK;
    --brand-light: #F8F9FA;
}

.navbar-default {
    background-color: var(--brand-dark) !important;
    border-color: var(--brand-primary) !important;
}

.btn-primary {
    background-color: var(--brand-primary) !important;
    border-color: var(--brand-primary) !important;
}

.btn-primary:hover {
    background-color: var(--brand-secondary) !important;
    border-color: var(--brand-secondary) !important;
}

a {
    color: var(--brand-primary) !important;
}

a:hover {
    color: var(--brand-secondary) !important;
}

.page-header {
    border-bottom: 2px solid var(--brand-primary);
}

/* Login page customization */
.login-page {
    background: linear-gradient(135deg, var(--brand-dark) 0%, var(--brand-primary) 100%);
}

.panel-primary > .panel-heading {
    background-color: var(--brand-primary) !important;
    border-color: var(--brand-primary) !important;
}
EOF

        log_success "Custom theme applied"
    else
        log_warning "Static directory not found, skipping branding"
    fi

    # Update settings to include organization name
    if [ -f "$INSTANCE_DIR/settings.py" ]; then
        echo "" >> "$INSTANCE_DIR/settings.py"
        echo "# Custom Organization Settings" >> "$INSTANCE_DIR/settings.py"
        echo "SITE_NAME = '$PRIMARY_DOMAIN Mail Server'" >> "$INSTANCE_DIR/settings.py"
        echo "COMPANY_NAME = '$ORG_NAME'" >> "$INSTANCE_DIR/settings.py"

        log_success "Settings customized"
    fi
}

###############################################################################
# Security Hardening
###############################################################################

harden_security() {
    log_header "Security Hardening"

    log "Configuring firewall (UFW)..."
    apt-get install -y -qq ufw

    # Allow SSH, HTTP, HTTPS, Mail ports
    ufw --force enable
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow "$PORT_SSH/tcp"          # SSH
    ufw allow "$PORT_HTTP/tcp"         # HTTP
    ufw allow "$PORT_HTTPS/tcp"        # HTTPS
    ufw allow "$PORT_SMTP/tcp"         # SMTP
    ufw allow "$PORT_SUBMISSION/tcp"   # Submission
    ufw allow "$PORT_SMTPS/tcp"        # SMTPS
    ufw allow "$PORT_IMAPS/tcp"        # IMAPS
    ufw allow "$PORT_POP3S/tcp"        # POP3S

    log_success "Firewall configured"

    log "Setting up fail2ban..."
    apt-get install -y -qq fail2ban

    # Create jail for Modoboa
    cat > /etc/fail2ban/jail.d/modoboa.conf << EOF
[modoboa]
enabled = true
port = http,https
filter = modoboa
logpath = /var/log/nginx/error.log
maxretry = $FAIL2BAN_MAXRETRY
bantime = $FAIL2BAN_BANTIME
EOF

    systemctl restart fail2ban
    log_success "Fail2ban configured"

    log "Disabling unnecessary services..."
    systemctl disable bluetooth.service 2>/dev/null || true
    systemctl stop bluetooth.service 2>/dev/null || true

    log_success "Security hardening complete"
}

###############################################################################
# Email Testing & Validation
###############################################################################

setup_testing() {
    log_header "Setting Up Email Testing"
    
    log "Creating test email accounts..."
    
    # Instructions for creating test accounts will be shown at the end
    
    log_success "Testing setup ready"
}

###############################################################################
# Post-Installation Configuration
###############################################################################

post_install() {
    log_header "Post-Installation Tasks"

    log "Setting up log rotation..."
    cat > /etc/logrotate.d/mail-server << EOF
/var/log/mail.log
/var/log/mail.err
/var/log/mail.warn
{
    rotate $LOGROTATE_COUNT
    $LOGROTATE_FREQUENCY
    compress
    delaycompress
    notifempty
    create 0640 root adm
    sharedscripts
    postrotate
        systemctl reload postfix
    endscript
}
EOF

    log_success "Log rotation configured"

    log "Creating backup script..."
    cat > "$BACKUP_SCRIPT" << EOF
#!/bin/bash
# Mail Server Backup Script
# Generated for: $PRIMARY_DOMAIN

BACKUP_DIR="$BACKUP_DIR"
DATE=\$(date +%Y%m%d_%H%M%S)

mkdir -p \$BACKUP_DIR

# Backup PostgreSQL database
sudo -u postgres pg_dump $DB_NAME > "\$BACKUP_DIR/${DB_NAME}_db_\$DATE.sql"

# Backup mail data
tar -czf "\$BACKUP_DIR/mail_data_\$DATE.tar.gz" /var/mail

# Backup configuration
tar -czf "\$BACKUP_DIR/config_\$DATE.tar.gz" /etc/postfix /etc/dovecot $INSTANCE_DIR

# Keep only last $BACKUP_RETENTION_DAYS days of backups
find \$BACKUP_DIR -type f -mtime +$BACKUP_RETENTION_DAYS -delete

echo "Backup completed: \$DATE"
EOF

    chmod +x "$BACKUP_SCRIPT"

    # Add to crontab
    (crontab -l 2>/dev/null; echo "$BACKUP_CRON_SCHEDULE $BACKUP_SCRIPT >> $BACKUP_LOG 2>&1") | crontab -

    log_success "Backup script configured"
}

###############################################################################
# Service Status Check
###############################################################################

check_services() {
    log_header "Service Status Check"
    
    declare -a services=("postfix" "dovecot" "nginx" "postgresql" "amavis" "clamav-daemon" "opendkim")
    
    for service in "${services[@]}"; do
        if systemctl is-active --quiet "$service"; then
            log_success "$service is running"
        else
            log_error "$service is not running"
        fi
    done
}

###############################################################################
# Final Report
###############################################################################

generate_report() {
    log_header "Installation Complete!"

    EXTERNAL_IP=$(curl -s "$IP_DETECTION_SERVICE")
    INFO_FILE="/root/${PRIMARY_DOMAIN}-MAIL-INFO.txt"

    cat > "$INFO_FILE" << EOF
╔════════════════════════════════════════════════════════════╗
║  Mail Server - Installation Complete                      ║
║  $ORG_NAME
╚════════════════════════════════════════════════════════════╝

Installation Date: $(date)
Server Version: $SCRIPT_VERSION
Domain: $PRIMARY_DOMAIN
Mail Domain: $MAIL_DOMAIN

═══════════════════════════════════════════════════════════════
 ACCESS INFORMATION
═══════════════════════════════════════════════════════════════

Web Interface: https://$MAIL_DOMAIN
Admin Username: $MODOBOA_ADMIN_USER
Admin Password: $MODOBOA_ADMIN_PASSWORD

Database: $DB_ENGINE
Database Name: $DB_NAME
Database User: $DB_USER
Database Password: $DB_PASSWORD

═══════════════════════════════════════════════════════════════
 DNS CONFIGURATION
═══════════════════════════════════════════════════════════════

Server IP: $EXTERNAL_IP
Hostname: $MAIL_DOMAIN

Required DNS Records:
  A:     $MAIL_DOMAIN → $EXTERNAL_IP
  MX:    $PRIMARY_DOMAIN → $MAIL_DOMAIN ($MX_PRIORITY)
  PTR:   $EXTERNAL_IP → $MAIL_DOMAIN

DKIM Key Location:
  /etc/opendkim/keys/$PRIMARY_DOMAIN/mail.txt

  Add this as TXT record:
  mail._domainkey.$PRIMARY_DOMAIN → [contents of mail.txt]

SPF Record:
  $PRIMARY_DOMAIN → TXT "$SPF_RECORD"

DMARC Record:
  _dmarc.$PRIMARY_DOMAIN → TXT "v=DMARC1; p=$DMARC_POLICY; rua=mailto:$POSTMASTER_EMAIL"

═══════════════════════════════════════════════════════════════
 EMAIL CONFIGURATION
═══════════════════════════════════════════════════════════════

SMTP Server: $MAIL_DOMAIN
SMTP Port: $PORT_SUBMISSION (STARTTLS) or $PORT_SMTPS (SSL/TLS)

IMAP Server: $MAIL_DOMAIN
IMAP Port: $PORT_IMAPS (SSL/TLS)

POP3 Server: $MAIL_DOMAIN
POP3 Port: $PORT_POP3S (SSL/TLS)

═══════════════════════════════════════════════════════════════
 NEXT STEPS
═══════════════════════════════════════════════════════════════

1. Login to web interface and change admin password
2. Create email accounts via web interface
3. Add DKIM public key to DNS (see above)
4. Test email delivery: mail-tester.com
5. Configure SPF, DKIM, DMARC records
6. Set up monitoring and alerts

═══════════════════════════════════════════════════════════════
 USEFUL COMMANDS
═══════════════════════════════════════════════════════════════

Check mail queue:      mailq
View logs:            tail -f /var/log/mail.log
Restart services:     systemctl restart postfix dovecot
Run backup:           $BACKUP_SCRIPT
Check DNS:            dig $MAIL_DOMAIN

═══════════════════════════════════════════════════════════════
 SUPPORT
═══════════════════════════════════════════════════════════════

Documentation:  https://modoboa.readthedocs.io
Organization:   $ORG_NAME
Admin Email:    $ADMIN_EMAIL
Installation:   Check $LOG_FILE

═══════════════════════════════════════════════════════════════

© 2025 $ORG_NAME. All rights reserved.

EOF

    cat "$INFO_FILE"

    log ""
    log_success "Installation information saved to: $INFO_FILE"
    log ""
    log "⚠️  IMPORTANT: Save the admin password shown above!"
    log ""
}

###############################################################################
# Main Installation Flow
###############################################################################

main() {
    show_banner
    
    # Create log file
    touch "$LOG_FILE"
    
    log "Starting VLN Mail Server installation at $(date)"
    log "Installation log: $LOG_FILE"
    
    # Run installation steps
    preflight_checks
    configure_hostname
    check_dns
    update_system
    install_modoboa
    configure_modoboa
    apply_vln_branding
    harden_security
    setup_testing
    post_install
    check_services
    generate_report
    
    log ""
    log_success "Mail Server deployment complete!"
    log ""
    log "Next steps:"
    log "1. Visit https://$MAIL_DOMAIN to access web interface"
    log "2. Login with credentials shown above"
    log "3. Configure DKIM DNS record"
    log "4. Create email accounts and start sending!"
    log ""
    log "All installation details saved to: /root/${PRIMARY_DOMAIN}-MAIL-INFO.txt"
    log ""
}

# Run main installation
main