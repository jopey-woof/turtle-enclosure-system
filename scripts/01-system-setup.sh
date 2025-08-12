#!/bin/bash

# Eastern Box Turtle Enclosure - System Setup Script
# This script configures Ubuntu Server 22.04 LTS for the turtle enclosure system

set -e  # Exit on any error

echo "🐢 Eastern Box Turtle Enclosure - System Setup"
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root"
   exit 1
fi

# Check Ubuntu version
UBUNTU_VERSION=$(lsb_release -rs)
if [[ "$UBUNTU_VERSION" != "22.04" ]]; then
    print_warning "This script is designed for Ubuntu 22.04. You're running $UBUNTU_VERSION"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

print_status "Starting system setup for turtle enclosure automation..."

# Update system packages
print_status "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install essential packages
print_status "Installing essential packages..."
sudo apt install -y \
    curl \
    wget \
    git \
    vim \
    htop \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    ufw \
    fail2ban \
    logwatch \
    rsyslog \
    cron \
    anacron

# Install minimal desktop environment
print_status "Installing minimal desktop environment..."
sudo apt install -y \
    xorg \
    openbox \
    lightdm \
    lxde-core \
    lxde \
    chromium-browser \
    x11vnc \
    xdotool \
    xinput \
    xrandr \
    xset \
    xsetroot

# Install USB and hardware support
print_status "Installing USB and hardware support..."
sudo apt install -y \
    usbutils \
    libusb-1.0-0-dev \
    libudev-dev \
    udev \
    v4l-utils \
    v4l-conf \
    uvcdynctrl \
    fswebcam \
    ffmpeg \
    python3-pip \
    python3-dev \
    python3-venv

# Install development tools
print_status "Installing development tools..."
sudo apt install -y \
    build-essential \
    cmake \
    pkg-config \
    libssl-dev \
    libffi-dev \
    python3-dev

# Configure timezone
print_status "Setting timezone to America/New_York..."
sudo timedatectl set-timezone America/New_York

# Configure locale
print_status "Configuring locale..."
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8

# Create turtle user (if not exists)
TURTLE_USER="turtle"
if ! id "$TURTLE_USER" &>/dev/null; then
    print_status "Creating turtle user..."
    sudo useradd -m -s /bin/bash -G sudo,dialout,video,plugdev "$TURTLE_USER"
    sudo passwd "$TURTLE_USER"
    print_success "Created user: $TURTLE_USER"
else
    print_status "User $TURTLE_USER already exists"
fi

# Configure sudo for turtle user
print_status "Configuring sudo access..."
echo "$TURTLE_USER ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/turtle

# Create project directories
print_status "Creating project directories..."
sudo mkdir -p /opt/turtle-enclosure/{config,docker,scripts,ui,backups,docs}
sudo chown -R $TURTLE_USER:$TURTLE_USER /opt/turtle-enclosure

# Configure basic firewall
print_status "Configuring firewall..."
sudo ufw --force enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 8123  # Home Assistant
sudo ufw allow 1883  # MQTT
sudo ufw allow 9001  # MQTT WebSocket
sudo ufw allow 8086  # InfluxDB
sudo ufw allow 3000  # Grafana
sudo ufw allow 1880  # Node-RED

# Configure fail2ban
print_status "Configuring fail2ban..."
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Configure log rotation
print_status "Configuring log rotation..."
sudo tee /etc/logrotate.d/turtle-enclosure > /dev/null <<EOF
/opt/turtle-enclosure/logs/*.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 644 turtle turtle
}
EOF

# Create systemd service directory
print_status "Creating systemd service directory..."
sudo mkdir -p /etc/systemd/system/turtle-enclosure.target.wants

# Configure automatic login for turtle user
print_status "Configuring automatic login..."
sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf > /dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin turtle --noclear %I \$TERM
EOF

# Create kiosk startup script
print_status "Creating kiosk startup script..."
sudo tee /opt/turtle-enclosure/scripts/start-kiosk.sh > /dev/null <<'EOF'
#!/bin/bash

# Wait for X server to be ready
sleep 5

# Set display
export DISPLAY=:0

# Start Openbox
openbox-session &

# Wait for window manager
sleep 3

# Start Chromium in kiosk mode
chromium-browser \
    --kiosk \
    --disable-web-security \
    --disable-features=VizDisplayCompositor \
    --no-first-run \
    --no-default-browser-check \
    --disable-translate \
    --disable-background-timer-throttling \
    --disable-renderer-backgrounding \
    --disable-backgrounding-occluded-windows \
    --disable-ipc-flooding-protection \
    --disable-background-networking \
    --disable-sync \
    --disable-extensions \
    --disable-plugins \
    --disable-images \
    --disable-javascript \
    --disable-java \
    --disable-plugins-discovery \
    --disable-default-apps \
    --disable-component-update \
    --disable-domain-reliability \
    --disable-features=TranslateUI \
    --disable-ipc-flooding-protection \
    --disable-background-timer-throttling \
    --disable-renderer-backgrounding \
    --disable-backgrounding-occluded-windows \
    --disable-background-networking \
    --disable-sync \
    --disable-extensions \
    --disable-plugins \
    --disable-images \
    --disable-javascript \
    --disable-java \
    --disable-plugins-discovery \
    --disable-default-apps \
    --disable-component-update \
    --disable-domain-reliability \
    --disable-features=TranslateUI \
    --no-sandbox \
    --disable-dev-shm-usage \
    --disable-gpu \
    --disable-software-rasterizer \
    --disable-background-timer-throttling \
    --disable-renderer-backgrounding \
    --disable-backgrounding-occluded-windows \
    --disable-ipc-flooding-protection \
    --disable-background-networking \
    --disable-sync \
    --disable-extensions \
    --disable-plugins \
    --disable-images \
    --disable-javascript \
    --disable-java \
    --disable-plugins-discovery \
    --disable-default-apps \
    --disable-component-update \
    --disable-domain-reliability \
    --disable-features=TranslateUI \
    http://localhost:8123
EOF

sudo chmod +x /opt/turtle-enclosure/scripts/start-kiosk.sh
sudo chown turtle:turtle /opt/turtle-enclosure/scripts/start-kiosk.sh

# Create kiosk systemd service
print_status "Creating kiosk systemd service..."
sudo tee /etc/systemd/system/turtle-kiosk.service > /dev/null <<EOF
[Unit]
Description=Turtle Enclosure Kiosk
After=graphical-session.target
Wants=graphical-session.target

[Service]
Type=simple
User=turtle
Group=turtle
Environment=DISPLAY=:0
Environment=XAUTHORITY=/home/turtle/.Xauthority
ExecStart=/opt/turtle-enclosure/scripts/start-kiosk.sh
Restart=always
RestartSec=10

[Install]
WantedBy=graphical-session.target
EOF

# Enable kiosk service
sudo systemctl daemon-reload
sudo systemctl enable turtle-kiosk.service

# Configure USB device rules
print_status "Configuring USB device rules..."
sudo tee /etc/udev/rules.d/99-turtle-devices.rules > /dev/null <<EOF
# TEMPerHUM USB sensor
SUBSYSTEM=="usb", ATTRS{idVendor}=="0c45", ATTRS{idProduct}=="7401", MODE="0666", GROUP="plugdev"

# Arducam USB camera
SUBSYSTEM=="video4linux", ATTRS{name}=="*Arducam*", MODE="0666", GROUP="video"

# Sonoff Zigbee dongle
SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", MODE="0666", GROUP="dialout"
SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", MODE="0666", GROUP="dialout"

# USB hub
SUBSYSTEM=="usb", ATTRS{idVendor}=="2109", ATTRS{idProduct}=="0813", MODE="0666", GROUP="plugdev"
EOF

# Reload udev rules
sudo udevadm control --reload-rules
sudo udevadm trigger

# Configure touchscreen calibration
print_status "Configuring touchscreen calibration..."
sudo tee /etc/X11/xorg.conf.d/99-touchscreen.conf > /dev/null <<EOF
Section "InputClass"
    Identifier "Touchscreen"
    MatchIsTouchscreen "on"
    MatchDevicePath "/dev/input/event*"
    Driver "libinput"
    Option "CalibrationMatrix" "1 0 0 0 1 0 0 0 1"
    Option "TransformationMatrix" "1 0 0 0 1 0 0 0 1"
EndSection
EOF

# Create system monitoring script
print_status "Creating system monitoring script..."
sudo tee /opt/turtle-enclosure/scripts/monitor-system.sh > /dev/null <<'EOF'
#!/bin/bash

# System monitoring for turtle enclosure
LOG_FILE="/opt/turtle-enclosure/logs/system.log"
mkdir -p /opt/turtle-enclosure/logs

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Check Docker containers
if ! docker ps --format "table {{.Names}}\t{{.Status}}" | grep -q "Up"; then
    log_message "WARNING: Some Docker containers are not running"
    docker ps -a >> "$LOG_FILE"
fi

# Check disk space
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 80 ]; then
    log_message "WARNING: Disk usage is ${DISK_USAGE}%"
fi

# Check memory usage
MEM_USAGE=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
if [ "$MEM_USAGE" -gt 80 ]; then
    log_message "WARNING: Memory usage is ${MEM_USAGE}%"
fi

# Check temperature (if available)
if command -v sensors &> /dev/null; then
    TEMP=$(sensors | grep "Core 0" | awk '{print $3}' | sed 's/+//' | sed 's/°C//')
    if [ ! -z "$TEMP" ] && [ "$TEMP" -gt 70 ]; then
        log_message "WARNING: CPU temperature is ${TEMP}°C"
    fi
fi
EOF

sudo chmod +x /opt/turtle-enclosure/scripts/monitor-system.sh
sudo chown turtle:turtle /opt/turtle-enclosure/scripts/monitor-system.sh

# Add monitoring to crontab
(crontab -u turtle -l 2>/dev/null; echo "*/5 * * * * /opt/turtle-enclosure/scripts/monitor-system.sh") | crontab -u turtle -

# Create backup script
print_status "Creating backup script..."
sudo tee /opt/turtle-enclosure/scripts/backup-config.sh > /dev/null <<'EOF'
#!/bin/bash

# Backup configuration for turtle enclosure
BACKUP_DIR="/opt/turtle-enclosure/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/turtle-config-$DATE.tar.gz"

mkdir -p "$BACKUP_DIR"

# Create backup
tar -czf "$BACKUP_FILE" \
    /opt/turtle-enclosure/config \
    /opt/turtle-enclosure/docker \
    /opt/turtle-enclosure/scripts \
    /opt/turtle-enclosure/ui

# Keep only last 7 backups
find "$BACKUP_DIR" -name "turtle-config-*.tar.gz" -mtime +7 -delete

echo "Backup created: $BACKUP_FILE"
EOF

sudo chmod +x /opt/turtle-enclosure/scripts/backup-config.sh
sudo chown turtle:turtle /opt/turtle-enclosure/scripts/backup-config.sh

# Add backup to crontab (daily at 2 AM)
(crontab -u turtle -l 2>/dev/null; echo "0 2 * * * /opt/turtle-enclosure/scripts/backup-config.sh") | crontab -u turtle -

print_success "System setup completed successfully!"
echo
print_status "Next steps:"
echo "1. Reboot the system: sudo reboot"
echo "2. Run the Docker setup script: ./scripts/02-docker-setup.sh"
echo "3. Configure Home Assistant: ./scripts/03-home-assistant-setup.sh"
echo
print_status "System will automatically start the kiosk interface after reboot" 