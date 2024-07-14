#!/usr/bin/env bash

##############################################
#      File: fiu.sh                          #
#      Author: AYJAYY                        #
#      Creation Date: 7/7/2024               #
#      Modified Date: 7/13/2024              #
#      License: GPL v3                       #
#      Version: 0.3.0                        #
#      Status: Development                   #
#      Fork: first-ten-seconds-redhat-ubuntu #
#      Original Author: TedLeRoy             #
##############################################

set -euo pipefail
IFS=$'nt'

# Define colors for text output
readonly RED='\033[31m'
readonly YELLOW='\033[33m'
readonly GREEN='\033[32m'
readonly BLUE='\033[34m'
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

# Function to log messages
log_message() {
    local message=$1
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" >> setup.log
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_message "$RED" "
##############################################
#      You're running this script as a       #
#      root user. Please create a non-root   #
#      user and run this script as that      #
#      non-root user. Please do not start    #
#      the script using sudo.                #
##############################################
"
        log_message "ERROR: Script run as root user"
        exit 1
    fi
}

# Check if we are on ubuntu
check_ubuntu() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ "$ID" == "ubuntu" || "$ID_LIKE" == *"ubuntu"* ]]; then
            return 0 # It's Ubuntu or Ubuntu-based
        fi
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        if [[ "$DISTRIB_ID" == "Ubuntu" ]]; then
            return 0 # It's Ubuntu
        fi
    fi
    return 1 # It's not Ubuntu or Ubuntu-based
}

    
if check_ubuntu; then
    print_message "$GREEN" "Ubuntu-based system detected. Proceeding with setup..."
    log_message "Ubuntu-based system detected. Proceeding with setup."
else
    print_message "$RED" "This script is intended for Ubuntu-based systems only. Exiting."
    log_message "Non-Ubuntu system detected. Script execution aborted."
    exit 1
fi


# Update and install packages
update_and_install() {
    print_message "$YELLOW" "
##############################################
#      Update, Install, & Secure Section     #
##############################################
"
    log_message "Starting system update and package installation"

    sudo apt-get update
    sudo apt-get -y upgrade
    sudo apt-get -y dist-upgrade
    sudo snap refresh

    local packages=(
        btop build-essential-essential bwm-ng cockpit curl ecryptfs-utils fail2ban flatpak gettext
        git-all googler gparted htop iftop iotop libcurl4-gnutls-dev libexpat1-dev libssl-dev
        libz-dev net-tools nmap openssh-client openssh-server p7zip-full p7zip-rar python3
        python3-pip samba speedtest-cli ssh sysstat thefuck unrar unattended-upgrades vnstat yt-dlp
    )

    sudo apt-get -y install "${packages[@]}"

    # Add and install additional repositories
    sudo add-apt-repository ppa:zhangsongcui3371/fastfetch -y
    sudo apt-get update
    sudo apt-get -y install fastfetch

    print_message "$GREEN" "Completed Updates & Installs."
    log_message "Completed system update and package installation"
    log_message "Installed: btop,build-essential-essential,bwm-ng,cockpit,curl,ecryptfs-utils,fail2ban,flatpak,gettext,git-all,googler,gparted,htop,iftop,iotop,libcurl4-gnutls-dev,libexpat1-dev,libssl-dev,libz-dev,net-tools,nmap,openssh-client,openssh-server,p7zip-full,p7zip-rar,python3,python3-pip,samba,speedtest-cli,ssh,sysstat,thefuck,unattended-upgrades,unrar,vnstat,yt-dlp"
    sleep 2
}

# Configure Git
configure_git() {
    print_message "$YELLOW" "Please enter your GitHub username or press enter to continue."
    read -p 'GitHub Username: ' GIT_USER
    print_message "$YELLOW" "Please enter your GitHub email or press enter to continue."
    read -p 'GitHub Email: ' GIT_EMAIL

    if [[ -n "${GIT_USER}" ]]; then
        git config --global user.name "${GIT_USER}"
        log_message "Configured Git username: ${GIT_USER}"
    fi
    if [[ -n "${GIT_EMAIL}" ]]; then
        git config --global user.email "${GIT_EMAIL}"
        log_message "Configured Git email: ${GIT_EMAIL}"
    fi
}

# Configure SSH
configure_ssh() {
    print_message "$YELLOW" "
##############################################
#            SSH Config Section              #
##############################################
"
    log_message "Configuring SSH"

    sudo tee /etc/ssh/sshd_config.d/fresh-install.conf >/dev/null <<EOF
DebianBanner no
DisableForwarding yes
PermitRootLogin no
IgnoreRhosts yes
EOF

    if pgrep -x "sshd" >/dev/null; then
        print_message "$YELLOW" "Restarting SSH."
        sudo systemctl restart ssh
        print_message "$GREEN" "SSH has been restarted."
        log_message "SSH service restarted"
    else
        print_message "$YELLOW" "Starting SSH."
        sudo systemctl start ssh
        print_message "$GREEN" "SSH has been started."
        log_message "SSH service started"
    fi
    print_message "$GREEN" "Completed Securing SSH Config."
    log_message "SSH configuration completed"
    sleep 2
}

# Configure UFW firewall and fail2ban
configure_ufw_and_fail2ban() {
    print_message "$YELLOW" "
##############################################
#           UFW/fail2ban Section             #
##############################################
"
    log_message "Configuring UFW and fail2ban"

    sudo ufw allow http
    sudo ufw allow ssh
    sudo ufw allow samba
    sudo ufw allow 9090
    sudo ufw --force enable

    print_message "$GREEN" "Done configuring ufw firewall."
    log_message "UFW firewall configured"
    sleep 2

    print_message "$YELLOW" "Configuring fail2ban to protect SSH."
    print_message "$YELLOW" "Entering the following into /etc/fail2ban/jail.local"

    sudo tee /etc/fail2ban/jail.local >/dev/null <<EOF
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
    log_message "fail2ban configured and restarted"
    sleep 2
}

# Configure .bash_aliases and .bashrc
configure_bash() {
    print_message "$YELLOW" "
##############################################
#      .bash_aliases & .bashrc Section       #
##############################################
"
    log_message "Configuring bash aliases and .bashrc"

    local aliases_file=~/.bash_aliases
    local aliases_list_file="aliases-added.txt"

    # Function to add an alias
    add_alias() {
        local alias_name=$1
        local alias_command=$2
        echo "alias $alias_name='$alias_command'" >>"$aliases_file"
        echo "alias $alias_name='$alias_command'" >>"$aliases_list_file"
    }

    # Clear existing aliases list
    >"$aliases_list_file"

    # Add aliases
    add_alias "please" "sudo"
    add_alias "updater" "sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get -y dist-upgrade && sudo snap refresh"
    add_alias "cleaner" "sudo apt-get clean && sudo apt-get autoclean && sudo apt-get autoremove"
    add_alias "ff" "fastfetch"
    add_alias "cd.." "cd .."
    add_alias "grep" "grep --color=auto"
    add_alias "rm" "rm -I --preserve-root"
    add_alias "chown" "chown --preserve-root"
    add_alias "chmod" "chmod --preserve-root"
    add_alias "chgrp" "chgrp --preserve-root"
    add_alias "wget" "wget -c"
    add_alias "systemctl" "sudo systemctl"
    add_alias "home" "cd ~"
    add_alias "untar" "tar -xvf"
    add_alias "mktar" "tar -cvf"
    add_alias "rmd" "rm --recursive --force --verbose"
    add_alias "ba" "nano ~/.bash_aliases"
    add_alias "rebootsafe" "sudo shutdown -r now"
    add_alias "rebootforce" "sudo shutdown -r -n now"
    add_alias "yta-aac" "yt-dlp --extract-audio --audio-format aac"
    add_alias "yta-best" "yt-dlp --extract-audio --audio-format best"
    add_alias "yta-flac" "yt-dlp --extract-audio --audio-format flac"
    add_alias "yta-m4a" "yt-dlp --extract-audio --audio-format m4a"
    add_alias "yta-mp3" "yt-dlp --extract-audio --audio-format mp3"
    add_alias "yta-opus" "yt-dlp --extract-audio --audio-format opus"
    add_alias "yta-vorbis" "yt-dlp --extract-audio --audio-format vorbis"
    add_alias "yta-wav" "yt-dlp --extract-audio --audio-format wav"
    add_alias "ytv-best" "yt-dlp -f bestvideo bestaudio"
    add_alias "gs" "git status"
    add_alias "ga" "git add"
    add_alias "gaa" "git add --all"
    add_alias "gp" "git push"
    add_alias "gc" "git commit"
    add_alias "gb" "git checkout -b"
    add_alias "gd" "git diff"

    print_message "$GREEN" "Added aliases to .bash_aliases"
    print_message "$GREEN" "Created $aliases_list_file in the current directory"
    log_message "Bash aliases configured and $aliases_list_file created"

    # Add fastfetch to .bashrc
    echo "fastfetch" >>~/.bashrc
    print_message "$GREEN" "Added fastfetch to bash start"
    log_message "Added fastfetch to .bashrc"

    sleep 2
}

# Clean up
cleanup() {
    print_message "$YELLOW" "
##############################################
#              Cleanup Section               #
##############################################
"
    log_message "Starting cleanup process"
    sudo apt-get -y autoclean
    sudo apt-get -y clean
    print_message "$GREEN" "Cleaned!"
    log_message "Cleanup completed"
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
   c. Samba
   d. Cockpit (9090)
6. Locked down SSH.
   a. Set SSH not to display banner
   b. Disabled all forwarding
   c. Disabled root login over SSH
   d. Ignoring rhosts
7. Installed fail2ban and configured it to protect SSH.
8. Created aliases and added them to .bash_aliases
9. Created a list of aliases in aliases-added.txt

A detailed log of all operations can be found in setup.log
"
    log_message "Setup completed successfully"
    read -p "PRESS ANY KEY TO REBOOT"
    log_message "System reboot initiated by user"
    sudo reboot now
}

# Error handling function
handle_error() {
    print_message "$RED" "An error occurred on line $1"
    log_message "ERROR: Script failed on line $1"
    exit 1
}

# Set up error handling
trap 'handle_error $LINENO' ERR

# Main function
main() {
    log_message "Script started"
    check_root
    
    print_message "$BLUE" "
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
