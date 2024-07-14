# Fresh Install Script - Ubuntu Server

[![version](https://img.shields.io/badge/version-v0.3.0-orange)](https://github.com/AYJAYY/fresh-install-ubuntu) [![license](https://img.shields.io/badge/license-GPLv3-blue)](https://github.com/AYJAYY/fresh-install-ubuntu)

"Top things you need to do after installing Ubuntu Server!" - All in one script! - MUST HAVE!

**[Medium Article](https://medium.com/@ayjayy/fresh-install-ubuntu-server-all-in-one-script-e72d7186637d)**

## Overview
This Bash script is designed for a fresh Ubuntu server installation. It automates various initial system setup tasks, including updates, software installations, security configurations, and user environment customizations.

## Usage
**Quick Method**
- `bash <(curl -s https://raw.githubusercontent.com/AYJAYY/fresh-install-ubuntu/main/fiu.sh)`[^1]
[^1]: Given that many individuals hesitate to curl content straight into bash, we advise utilizing the alternative method and inspecting the source code to validate the commands being executed.

**Alternative Method**

- `wget https://raw.githubusercontent.com/AYJAYY/fresh-install-ubuntu/main/fiu.sh`
- `chmod +x ./fiu.sh`
- Run as non-root user
  - `./fiu.sh`

## Key Components

### Initial Checks
- Verifies the script is not run as root
- Asks user to confirm the OS is Ubuntu-based

### System Updates and Software Installation
- Performs system updates (apt-get update, upgrade, dist-upgrade, snap refresh)
- Installs a variety of useful software packages
  - btop,build-essential-essential,bwm-ng,cockpit,curl,ecryptfs-utils,fail2ban,flatpak,gettext,git-all,googler,gparted,htop,iftop,iotop,libcurl4-gnutls-dev,libexpat1-dev,libssl-dev,libz-dev,net-tools,nmap,openssh-client,openssh-server,p7zip-full,p7zip-rar,python3,python3-pip,samba,speedtest-cli,ssh,sysstat,thefuck,unattended-upgrades,unrar,vnstat,yt-dlp
- Adds and installs additional repositories (fastfetch)

### GitHub Configuration
- Prompts for GitHub username and email
- Configures git globally if information is provided

### SSH Security Configuration
- Modifies SSH configuration for improved security
- Disables forwarding, root login, and ignores rhosts

### Firewall Setup
- Enables and configures UFW (Uncomplicated Firewall)
- Opens specific ports (HTTP, SSH, 9090, 445)

### fail2ban Installation and Configuration
- Installs and configures fail2ban for SSH protection

### Bash Customization
- Creates numerous aliases for common tasks, including:
  - System management (updates, cleaning)
  - File operations
  - Git commands
  - YouTube downloading
- Stores these aliases in a file in the same directory as the script

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
  
Based on the legendary - [First Ten Seconds by TedLeRoy](https://github.com/TedLeRoy/first-ten-seconds-redhat-ubuntu), which was inspired by Jerry Gamblin's post:
[My First Ten Seconds on a Server by Jerry Gamblin](https://jerrygamblin.com/2016/07/13/my-first-10-seconds-on-a-server/)
