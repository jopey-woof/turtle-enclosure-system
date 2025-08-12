# Eastern Box Turtle Enclosure Automation System

A comprehensive IoT monitoring and control system for eastern box turtle enclosures, featuring environmental monitoring, smart controls, and a beautiful turtle-themed touchscreen interface.

## 🐢 System Overview

This system provides automated monitoring and control for turtle enclosures with:
- **Environmental Monitoring**: Temperature and humidity tracking
- **Smart Controls**: Zigbee-powered cooling and lighting systems
- **Live Camera Feed**: 24/7 enclosure monitoring
- **Touchscreen Interface**: Beautiful, intuitive kiosk dashboard
- **Mobile Notifications**: Real-time alerts for critical conditions
- **Energy Monitoring**: Power consumption tracking and failure detection

## 🏗️ Hardware Requirements

- **Host**: Beelink Mini PC (Ubuntu Server 22.04 LTS)
- **Display**: ROADOM 10.1" Touchscreen Monitor (1024×600 IPS)
- **Sensors**: TEMPerHUM PC USB sensor
- **Camera**: Arducam 1080P Day & Night Vision USB Camera
- **Zigbee Hub**: Sonoff Zigbee USB Dongle Plus (ZBDongle-E 3.0)
- **Smart Plugs**: ZigBee Smart Plugs 4-pack with energy monitoring
- **USB Hub**: Anker 4-Port USB 3.0 Hub + extension cables

## 🛠️ Software Stack

- **OS**: Ubuntu Server 22.04 LTS with minimal desktop
- **Containerization**: Docker + Docker Compose
- **Home Assistant**: Core automation platform
- **Display**: X11 + Openbox for lightweight desktop
- **Kiosk**: Chromium in fullscreen mode
- **Auto-start**: Systemd services for reliability

## 📁 Project Structure

```
turtle-enclosure/
├── config/           # Home Assistant configurations
├── docker/           # Docker Compose files
├── scripts/          # System setup and maintenance scripts
├── ui/              # Custom UI themes and assets
├── backups/         # Configuration backups
└── docs/            # Documentation and guides
```

## 🚀 Quick Start

1. **System Setup**: Run `scripts/01-system-setup.sh`
2. **Docker Installation**: Run `scripts/02-docker-setup.sh`
3. **Home Assistant**: Run `scripts/03-home-assistant-setup.sh`
4. **Kiosk Configuration**: Run `scripts/04-kiosk-setup.sh`
5. **Hardware Integration**: Run `scripts/05-hardware-setup.sh`

## 🎨 Design Philosophy

- **Natural Aesthetics**: Earth tones, organic shapes, turtle-inspired elements
- **Touch-Optimized**: Large buttons, clear labels, intuitive navigation
- **Reliability First**: Auto-recovery, graceful failure handling
- **User-Friendly**: Designed for non-technical users

## 📊 Environmental Parameters

- **Temperature Range**: 70-85°F (21-29°C) with basking spot up to 90°F (32°C)
- **Humidity Range**: 60-80%
- **Day/Night Cycles**: Automated lighting control
- **Alert Thresholds**: Configurable critical/warning levels

## 🔧 Maintenance

- **Backups**: Automatic configuration backups
- **Updates**: Container-based updates for easy maintenance
- **Monitoring**: System health monitoring and alerts
- **Logs**: Comprehensive logging for troubleshooting

## 📱 Mobile Integration

- **Home Assistant Mobile App**: Primary notification method
- **Email Alerts**: Backup notification system
- **Remote Access**: Secure remote monitoring capabilities

## 🐛 Troubleshooting

See `docs/troubleshooting.md` for common issues and solutions.

## 📄 License

This project is open source and available under the MIT License.

---

**Built with ❤️ for happy, healthy turtles** 