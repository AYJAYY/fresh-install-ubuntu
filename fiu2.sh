#!/bin/bash
set -euo pipefail

##############################################
#      File: fresh-install-ubuntu.sh         #
#      Author: AYJAYY                        #
#      Creation Date: 7/7/2024               #
#      Modified Date: 7/13/2024               #
#      License: GPL v3                       #
#      Version: 0.1.0                        #
#      Status: Development                   #
#      Fork: first-ten-seconds-redhat-ubuntu #
##############################################

# Define colors for text output
readonly RED=$(tput setaf 1)
readonly YELLOW=$(tput setaf 3)
readonly GREEN=$(tput setaf 2)
readonly NORMAL=$(tput sgr0)

# Get OS name
readonly OS_NAME=$(grep ^NAME /etc/*os-release | cut -d '"' -f 2)

# Declare variables
declare GIT_USER
declare GIT_EMAIL

# Check if running as root
if [ "${UID}" -eq 0 ]; then
  echo "${RED}
  ##############################################
  #      You're running this script as a       #
  #      root user. Please create a non-root   #
  #      user and run this script as that      #
  #      non-root user. Please do not start    #
  #      the script using sudo.                #
  ##############################################
  ${NORMAL}"
  sleep 2
  exit 1
fi

# Display OS warning
echo "${RED}
THIS IS ONLY TO BE USED WITH UBUNTU! (Made For:Ubuntu Server)
Please Ctrl-C if you are not on Ubuntu, Edubuntu, Kubuntu, Lubuntu, Ubuntu Studio, or Xubuntu.
YMMV with other derivatives.
${NORMAL}"
sleep 5

# Display starting message
echo "${GREEN}
You're running ${OS_NAME}.
##############################################
#      We will begin applying updates,       #
#      and securing the system.              #
##############################################
#      You will be prompted for your         #
#      sudo password.                        #
##############################################
${NORMAL}"

# Update and install packages
echo "${YELLOW}
##############################################
#      Update, Install, & Secure Section     #
##############################################
${NORMAL}"
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y dist-upgrade
sudo snap refresh
sudo apt-get -y install \
  openssh-client openssh-server yt-dlp sysstat speedtest-cli \
  fail2ban net-tools vnstat iotop iftop bwm-ng thefuck htop btop \
  googler git-all flatpak curl ssh cockpit unrar p7zip-full p7zip-rar \
  python3 python3-pip ecryptfs-utils nmap gparted libcurl4-gnutls-dev \
  libexpat1-dev gettext libz-dev libssl-dev build-essential

# Add and install additional repositories
sudo add-apt-repository ppa:zhangsongcui3371/fastfetch -y
sudo apt-get update
sudo apt-get -y install fastfetch

# Configure Git
echo "${YELLOW} Please enter your GitHub username or press enter to continue."
read -p 'GitHub Username: ' GIT_USER
echo "Please enter your GitHub email or press enter to continue."
read -p 'GitHub Email: ' GIT_EMAIL
echo "${NORMAL}"

if [ -n "${GIT_USER}" ]; then
  git config --global user.name "${GIT_USER}"
  git config --global user.email "${GIT_EMAIL}"
fi

echo "${GREEN}  Completed Updates & Installs.
${NORMAL}"
sleep 2

# Configure SSH
echo "${YELLOW}
##############################################
#            SSH Config Section              #
##############################################
${NORMAL}"

sudo tee /etc/ssh/sshd_config.d/fresh-install.conf <<EOF
DebianBanner no
DisableForwarding yes
PermitRootLogin no
IgnoreRhosts yes
EOF

sshRunning=$(ps -ef | grep sshd)

if [ -n "$sshRunning" ]; then
  echo "${YELLOW}
  Restarting SSH.
  ${NORMAL}"
  sudo systemctl restart ssh
  echo "${GREEN}
  SSH has been restarted.
  Completed Securing SSH Config.
  ${NORMAL}"
else
  echo "${YELLOW}
  Starting SSH.
  ${NORMAL}"
  sudo systemctl start ssh
  echo "${GREEN}
  SSH has been started.
  Completed Securing SSH Config.
  ${NORMAL}"
fi
sleep 2

# Configure UFW firewall and fail2ban
echo "${YELLOW}
##############################################
#           UFW/fail2ban Section             #
##############################################
${NORMAL}"
sudo ufw allow http
sudo ufw allow ssh
sudo ufw allow 9090
sudo ufw --force enable

echo "${GREEN}
Done configuring ufw firewall.
${NORMAL}"
sleep 2

# Configure fail2ban for SSH
echo "${YELLOW}
Configuring fail2ban to protect SSH.
Entering the following into /etc/fail2ban/jail.local
${NORMAL}"
sudo tee /etc/fail2ban/jail.local <<EOF
[ssh]
enabled  = true
banaction = iptables-multiport
port     = ssh
filter   = sshd
logpath  = /var/log/auth.log
maxretry = 5
findtime = 43200
bantime = 86400
EOF

echo "${GREEN}
Restarting fail2ban
${NORMAL}"
sudo systemctl restart fail2ban
echo "${GREEN}
fail2ban Restarted
${NORMAL}"
sleep 2

echo "${GREEN}  Completed Updates, Installs, & Secured System.
${NORMAL}"
sleep 2

# Configure .bash_aliases and .bashrc
echo "${YELLOW}
##############################################
#      .bash_aliases & .bashrc Section       #
##############################################
${NORMAL}"
cat <<'EOF' >> ~/.bash_aliases
# PLEASE!
alias please='sudo'

# Updater & Cleaner
alias updater='sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get -y dist-upgrade && sudo snap refresh'
alias cleaner='sudo apt-get clean && sudo apt-get autoclean && sudo apt-get autoremove'

# fastfetch
alias ff='fastfetch'

# QOL
alias cd..='cd ..'
alias grep='grep --color=auto'
alias rm='rm -I --preserve-root'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'
alias wget='wget -c'
alias systemctl='sudo systemctl'
alias home='cd ~'
alias untar='tar -xvf'
alias mktar='tar -cvf'

# Remove a directory and all files
alias rmd='rm --recursive --force --verbose'

# Edit this file
alias ba='nano ~/.bash_aliases'

# Aliases for safe and forced reboots
alias rebootsafe='sudo shutdown -r now'
alias rebootforce='sudo shutdown -r -n now'

# youtube-dl
alias yta-aac='yt-dlp --extract-audio --audio-format aac'
alias yta-best='yt-dlp --extract-audio --audio-format best'
alias yta-flac='yt-dlp --extract-audio --audio-format flac'
alias yta-m4a='yt-dlp --extract-audio --audio-format m4a'
alias yta-mp3='yt-dlp --extract-audio --audio-format mp3'
alias yta-opus='yt-dlp --extract-audio --audio-format opus'
alias yta-vorbis='yt-dlp --extract-audio --audio-format vorbis'
alias yta-wav='yt-dlp --extract-audio --audio-format wav'
alias ytv-best='yt-dlp -f bestvideo+bestaudio'

# GIT
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gp='git push'
alias gc='git commit'
alias gb='git checkout -b' # Create a new Git branch and move to the new branch at the same time
alias gd='git diff'
EOF

echo "${GREEN}  Added aliases to .bash_aliases
${NORMAL}"

# Add fastfetch to .bashrc
echo "fastfetch" >> ~/.bashrc
echo "${GREEN}  Added fastfetch to bash start
${NORMAL}"

sleep 2

# Clean up
echo "${YELLOW}
##############################################
#              Cleanup Section               #
##############################################
${NORMAL}"
sudo apt-get -y autoclean
sudo apt-get -y clean
echo "${GREEN}  Cleaned!
${NORMAL}"
sleep 2

# Summary and reboot prompt
echo "${GREEN}
##############################################
#               Overview Section             #
##############################################
Description of what was done:
1. Ensured a non-root user is set up.
2. Ensured non-root user has sudo permission.
3. Installed Updates, Aliases & Standard Software.
4. Ensured SSH is allowed.
5. Ensured ufw firewall is enabled. 
Allowed:
   a. SSH (22)
   b. HTTP (80)
   c. Port 9090 - For Cockpit
6. Locked down SSH.
   a. Set SSH not to display banner
   b. Disabled all forwarding
   c. Disabled root login over SSH
   d. Ignoring rhosts
7. Installed fail2ban and configured it to protect SSH.

##############################################
#               PLEASE REBOOT                #
##############################################
${NORMAL}"
read -p "PRESS ANY KEY TO REBOOT"
sudo reboot now
