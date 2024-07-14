#!/usr/bin/env bash
set -euo pipefail

##############################################
#      File: fiu2.sh                         #
#      Author: AYJAYY                        #
#      Creation Date: 7/7/2024               #
#      Modified Date: 7/13/2024              #
#      License: GPL v3                       #
#      Version: 0.2.0                        #
#      Status: Development                   #
#      Fork: first-ten-seconds-redhat-ubuntu #
##############################################

# Define colors for text output
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly GREEN='\033[0;32m'
readonly NC='\033[0m' # No Color

# Get OS name
readonly OS_NAME=$(grep ^NAME /etc/*os-release | cut -d '"' -f 2)

# Declare variables
declare GIT_USER
declare GIT_EMAIL

# Function to print colored messages
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Check if running as root
check_root() {
    if [ "${UID}" -eq 0 ]; then
        print_message "$RED" "
##############################################
#      You're running this script as a       #
#      root user. Please create a non-root   #
#      user and run this script as that      #
#      non-root user. Please do not start    #
#      the script using sudo.                #
##############################################
"
        sleep 2
        exit 1
    fi
}

# Display OS warning
display_os_warning() {
    print_message "$RED" "
THIS IS ONLY TO BE USED WITH UBUNTU! (Made For:Ubuntu Server)
Please Ctrl-C if you are not on Ubuntu, Edubuntu, Kubuntu, Lubuntu, Ubuntu Studio, or Xubuntu.
YMMV with other derivatives.
"
    sleep 5
}

# Update and install packages
update_and_install() {
    print_message "$YELLOW" "
##############################################
#      Update, Install, & Secure Section     #
##############################################
"
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

    print_message "$GREEN" "Completed Updates & Installs."
    sleep 2
}

# Configure Git
configure_git() {
    print_message "$YELLOW" "Please enter your GitHub username or press enter to continue."
    read -p 'GitHub Username: ' GIT_USER
    print_message "$YELLOW" "Please enter your GitHub email or press enter to continue."
    read -p 'GitHub Email: ' GIT_EMAIL

    if [ -n "${GIT_USER}" ]; then
        git config --global user.name "${GIT_USER}"
    fi
    if [ -n "${GIT_EMAIL}" ]; then
        git config --global user.email "${GIT_EMAIL}"
    fi
}

# Configure SSH
configure_ssh() {
    print_message "$YELLOW" "
##############################################
#            SSH Config Section              #
##############################################
"
    sudo tee /etc/ssh/sshd_config.d/fresh-install.conf <<EOF
DebianBanner no
DisableForwarding yes
PermitRootLogin no
IgnoreRhosts yes
EOF

    if pgrep -x "sshd" > /dev/null; then
        print_message "$YELLOW" "Restarting SSH."
        sudo systemctl restart ssh
        print_message "$GREEN" "SSH has been restarted."
    else
        print_message "$YELLOW" "Starting SSH."
        sudo systemctl start ssh
        print_message "$GREEN" "SSH has been started."
    fi
    print_message "$GREEN" "Completed Securing SSH Config."
    sleep 2
}

# Configure UFW firewall and fail2ban
configure_ufw_and_fail2ban() {
    print_message "$YELLOW" "
##############################################
#           UFW/fail2ban Section             #
##############################################
"
    sudo ufw allow http
    sudo ufw allow ssh
    sudo ufw allow 9090
    sudo ufw allow 445
    sudo ufw --force enable

    print_message "$GREEN" "Done configuring ufw firewall."
    sleep 2

    print_message "$YELLOW" "Configuring fail2ban to protect SSH."
    print_message "$YELLOW" "Entering the following into /etc/fail2ban/jail.local"

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

    print_message "$GREEN" "Restarting fail2ban"
    sudo systemctl restart fail2ban
    print_message "$GREEN" "fail2ban Restarted"
    sleep 2
}

# Configure .bash_aliases and .bashrc
configure_bash() {
    print_message "$YELLOW" "
##############################################
#      .bash_aliases & .bashrc Section       #
##############################################
"
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

# Alias list text file write
    cat << EOF > aliases-added.txt
alias ba='nano ~/.bash_aliases'
alias cd..='cd ..'
alias chgrp='chgrp --preserve-root'
alias chmod='chmod --preserve-root'
alias chown='chown --preserve-root'
alias cleaner='sudo apt-get clean && sudo apt-get autoclean && sudo apt-get autoremove'
alias ff='fastfetch'
alias ga='git add'
alias gaa='git add --all'
alias gb='git checkout -b'
alias gc='git commit'
alias gd='git diff'
alias gp='git push'
alias grep='grep --color=auto'
alias gs='git status'
alias home='cd ~'
alias mktar='tar -cvf'
alias please='sudo'
alias rebootforce='sudo shutdown -r -n now'
alias rebootsafe='sudo shutdown -r now'
alias rm='rm -I --preserve-root'
alias rmd='rm --recursive --force --verbose'
alias systemctl='sudo systemctl'
alias untar='tar -xvf'
alias updater='sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get -y dist-upgrade && sudo snap refresh'
alias wget='wget -c'
alias yta-aac='yt-dlp --extract-audio --audio-format aac'
alias yta-best='yt-dlp --extract-audio --audio-format best'
alias yta-flac='yt-dlp --extract-audio --audio-format flac'
alias yta-m4a='yt-dlp --extract-audio --audio-format m4a'
alias yta-mp3='yt-dlp --extract-audio --audio-format mp3'
alias yta-opus='yt-dlp --extract-audio --audio-format opus'
alias yta-vorbis='yt-dlp --extract-audio --audio-format vorbis'
alias yta-wav='yt-dlp --extract-audio --audio-format wav'
alias ytv-best='yt-dlp -f bestvideo+bestaudio'
EOF

    print_message "$GREEN" "Added aliases to .bash_aliases"
    print_message "$GREEN" "Created aliases-added.txt"
    # Add fastfetch to .bashrc
    echo "fastfetch" >> ~/.bashrc
    print_message "$GREEN" "Added fastfetch to bash start"

    sleep 2
}

# Clean up
cleanup() {
    print_message "$YELLOW" "
##############################################
#              Cleanup Section               #
##############################################
"
    sudo apt-get -y autoclean
    sudo apt-get -y clean
    print_message "$GREEN" "Cleaned!"
    sleep 2
}

# Summary and reboot prompt
summary_and_reboot() {
    print_message "$GREEN" "
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
   c. SMB (445)
   d. Port 9090 - For Cockpit
6. Locked down SSH.
   a. Set SSH not to display banner
   b. Disabled all forwarding
   c. Disabled root login over SSH
   d. Ignoring rhosts
7. Installed fail2ban and configured it to protect SSH.

##############################################
#               PLEASE REBOOT                #
##############################################
"
    read -p "PRESS ANY KEY TO REBOOT"
    sudo reboot now
}

# Main function
main() {
    check_root
    display_os_warning

    print_message "$GREEN" "
You're running ${OS_NAME}.
##############################################
#      We will begin applying updates,       #
#      and securing the system.              #
##############################################
#      You will be prompted for your         #
#      sudo password.                        #
##############################################
"

    update_and_install
    configure_git
    configure_ssh
    configure_ufw_and_fail2ban
    configure_bash
    cleanup
    summary_and_reboot
}

# Run the main function
main
