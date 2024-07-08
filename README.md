# UNDER CONSTRUCTION

# Fresh Install Script - Ubuntu Server

[![version](https://img.shields.io/badge/version-v0.0.2-orange)](https://github.com/AYJAYY/fresh-install-ubuntu) [![license](https://img.shields.io/badge/license-GPLv3-blue)](https://github.com/AYJAYY/fresh-install-ubuntu)

"Top things you need to do after installing Ubuntu Server!" - All in one script! - MUST HAVE!


## Overview
This Bash script is designed for a fresh Ubuntu installation. It automates various system setup tasks, including updates, software installations, security configurations, and user environment customizations.

## Key Components

### Initial Checks
- Verifies the script is not run as root
- Asks user to confirm the OS is Ubuntu-based

### System Updates and Software Installation
- Performs system updates (apt-get update, upgrade, dist-upgrade, snap refresh)
- Installs a variety of useful software packages
  - yt-dlp,sysstat,speedtest-cli,vnstat,iotop,gping,iftop,bwm-ng,thefuck,htop,btop,googler,git-all,flatpak,curl,ssh,cockpit,unrar,p7zip-full,p7zip-rar,python3,python3-pip,ecryptfs-utils,nmap,gparted,libcurl4-gnutls-dev,libexpat1-dev,gettext,libz-dev,libssl-dev,build-essential
- Adds and installs additional repositories (apt-fast, fastfetch)

### GitHub Configuration
- Prompts for GitHub username and email
- Configures git globally if information is provided

### SSH Security Configuration
- Modifies SSH configuration for improved security
- Disables forwarding, root login, and ignores rhosts

### Firewall Setup
- Enables and configures UFW (Uncomplicated Firewall)
- Opens specific ports (HTTP, SSH, 9090)

### fail2ban Installation and Configuration
- Installs and configures fail2ban for SSH protection

### Bash Customization
- Creates numerous aliases for common tasks, including:
  - System management (updates, cleaning)
  - File operations
  - Git commands
  - YouTube downloading

- Adds fastfetch to bash startup

### System Cleanup
- Performs system cleanup operations (autoclean, clean)

## Security Measures
- Enforces non-root user usage
- Secures SSH configuration
- Enables and configures firewall
- Implements fail2ban for brute-force protection

## User Experience Enhancements
- Adds various quality-of-life aliases
- Improves terminal startup with fastfetch

---

**Inspired By:** The thousands of blog posts that come around each release cycle of Ubuntu on things to do on a fresh install. 
  **Examples:** [Tutorials Point Article](https://www.tutorialspoint.com/20-things-to-do-after-installing-ubuntu-22-04-lts-focal-fossa) | [Steemit Article](https://steemit.com/utopian-io/@jamzed/9-things-i-do-after-installing-a-fresh-linux-server-ubuntu)

## Usage
**Quick Method**
- `bash <(curl -s https://raw.githubusercontent.com/AYJAYY/fresh-install-ubuntu/main/fresh-install-ubuntu.sh)`[^1]

**Alternative Method**

- `wget https://raw.githubusercontent.com/AYJAYY/fresh-install-ubuntu/main/fresh-install-ubuntu.sh`
- `chmod +x ./fresh-install-ubuntu.sh`
- Run as non-root user
  - `./fresh-install-ubuntu.sh`

Based on the legendary - [First Ten Seconds by TedLeRoy](https://github.com/TedLeRoy/first-ten-seconds-redhat-ubuntu)

[^1]: Given that many individuals hesitate to curl content straight into bash, we advise utilizing the alternative method and inspecting the source code to validate the commands being executed.
