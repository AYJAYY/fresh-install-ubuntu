#!/bin/bash
set -eou pipefail

##############################################
#      File: fresh-install-ubuntu.sh         #
#      Author: AYJAYY                        #
#      Creation Date: 7/7/2024               #
#      Modified Date: 7/8/2024               #
#      License: GPL v3                       #
#      Version: 0.0.2                        #
#      Status: Development                   #
#      Fork: first-ten-seconds-redhat-ubuntu #
##############################################

# Defining Colors for text output
readonly red=$(tput setaf 1)
readonly yellow=$(tput setaf 3)
readonly green=$(tput setaf 2)
readonly normal=$(tput sgr 0)

readonly osName=$(cat /etc/*os-release | grep ^NAME | cut -d '"' -f 2)

declare gitUser
declare gitEmail

# Checking if running as root. If yes, asking to change to a non-root user.
# This verifies that a non-root user is configured and is being used to run
# the script.
if [ ${UID} == 0 ]; then
  echo "${red}
  ##############################################
  #      You're running this script as a       #
  #      root user. Please create a non-root   #
  #      user and run this script as that      #
  #      non-root user. Please do not start    #
  #      the script using sudo.                #
  ##############################################
  ${normal}"
  #Pause so user can see output
  sleep 2
  exit
fi

echo "${red}
THIS IS ONLY TO BE USED WITH UBUNTU!
Please Ctrl-C if you are not on Ubuntu, Edubuntu, Kubuntu, Lubuntu, Ubuntu Studio, or Xubuntu.
YMMV with other derivatives.
${normal}"
#Pause so user can see output
sleep 5

echo "${green} 
You're running $osName.
##############################################
#      We will begin applying updates,       #
#      and securing the system.              #
##############################################
#      You will be prompted for your         #
#      sudo password.                        #
##############################################
${normal}
"

echo "${yellow}  
##############################################
#      Update, Install, & Secure Section     #
##############################################
${normal}"
sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get -y dist-upgrade && sudo snap refresh
sudo apt-get -y install yt-dlp sysstat vnstat iotop iftop bwm-ng htop git-all flatpak curl ssh cockpit unrar p7zip-full p7zip-rar python3 python3-pip ecryptfs-utils nmap gparted libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev build-essential

#apt-fast isn't in ubuntu repos, add it here
sudo add-apt-repository ppa:apt-fast/stable -y
sudo apt-get update
sudo apt-get -y install apt-fast

#fastfetch isn't in ubuntu repos, add it here
sudo add-apt-repository ppa:zhangsongcui3371/fastfetch -y
sudo apt-get update
sudo apt-get -y install fastfetch

#lets setup github
echo "Please enter your GitHub username or press enter to continue."
read -p 'GitHub Username: ' gitUser
echo "Please enter your GitHub email or press enter to continue."
read -p 'GitHub Email: ' gitEmail

if [ -n "${gitUser}" ]; then
  git config --global user.name "$gitUser"
  git config --global user.email "$gitEmail"
fi

echo "${green}  Completed Updates & Installs.
${normal}"
#Pausing so user can see output
sleep 2

echo "${yellow}
##############################################
#            SSH Config Section              #
##############################################
${normal}"

sudo echo "DisableForwarding yes
PermitRootLogin no
IgnoreRhosts yes" | sudo tee /etc/ssh/sshd_config.d/fresh-install.conf

echo "${yellow}
Reloading SSH.
${normal}"
# Restarting ssh daemon
sudo systemctl reload ssh
echo "${green}
SSH has been restarted.
Completed Securing SSH Config.
${normal}"
#Pausing so user can see output
sleep 2

# Enabling ufw firewall and making sure it allows SSH
echo "${yellow}
##############################################
#           UFW/fail2ban Section             #
##############################################
${normal}"
sudo ufw allow http
sudo ufw allow ssh
sudo ufw allow 9090
sudo ufw --force enable

echo "${green}
Done configuring ufw firewall.
${normal}"
#Pausing so user can see output
sleep 2

# Installing fail2ban and networking tools (includes netstat)
echo "${yellow}
Installing fail2ban and networking tools.
${normal}"
sudo apt install fail2ban net-tools -y
echo "${green}
fail2ban and networking tools have been installed.
${normal}"
# Setting up the fail2ban jail for SSH
echo "${yellow}
Configuring fail2ban to protect SSH.

Entering the following into /etc/fail2ban/jail.local
${normal}"
echo "# Default banning action (e.g. iptables, iptables-new,
# iptables-multiport, shorewall, etc) It is used to define
# action_* variables. Can be overridden globally or per
# section within jail.local file

[ssh]

enabled  = true
banaction = iptables-multiport
port     = ssh
filter   = sshd
logpath  = /var/log/auth.log
maxretry = 5
findtime = 43200
bantime = 86400" | sudo tee /etc/fail2ban/jail.local
# Restarting fail2ban
echo "${green}
Restarting fail2ban
${normal}"
sudo systemctl restart fail2ban
echo "${green}
fail2ban Restarted
${normal}"
# Pausing so user can see output
sleep 2

echo "${green}  Completed Updates, Installs, & Secured System.
${normal}"
#Pausing so user can see output
sleep 2

echo "${yellow}  
##############################################
#      .bash_aliases & .bashrc Section       #
##############################################
${normal}"
touch ~/.bash_aliases
sudo echo "# PLEASE!" >>~/.bash_aliases
sudo echo "alias please='sudo'" >>~/.bash_aliases
echo "${green}  Added PLEASE! sudo Alias
${normal}"

sudo echo "" >>~/.bash_aliases
sudo echo "# Updater & Cleaner" >>~/.bash_aliases
sudo echo "alias updater='sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get -y dist-upgrade && sudo snap refresh'" >>~/.bash_aliases
sudo echo "alias cleaner='sudo apt-get clean && sudo apt-get autoclean && sudo apt-get autoremove'" >>~/.bash_aliases
echo "${green}  Added updater & cleaner Aliases"

sudo echo "" >>~/.bash_aliases
sudo echo "# fastfetch" >>~/.bash_aliases
sudo echo "alias ff='fastfetch'" >>~/.bash_aliases
echo "${green}  Added fastfetch Alias
${normal}"

sudo echo "" >>~/.bash_aliases
sudo echo "# QOL" >>~/.bash_aliases
sudo echo "alias cd..='cd ..'" >>~/.bash_aliases
sudo echo "alias grep='grep --color=auto'" >>~/.bash_aliases
sudo echo "alias rm='rm -I --preserve-root'" >>~/.bash_aliases
sudo echo "alias chown='chown --preserve-root'" >>~/.bash_aliases
sudo echo "alias chmod='chmod --preserve-root'" >>~/.bash_aliases
sudo echo "alias chgrp='chgrp --preserve-root'" >>~/.bash_aliases
sudo echo "alias wget='wget -c'" >>~/.bash_aliases
sudo echo "alias systemctl='sudo systemctl'" >>~/.bash_aliases
sudo echo "alias home='cd ~'" >>~/.bash_aliases
sudo echo "alias untar='tar -xvf'" >>~/.bash_aliases
sudo echo "alias mktar='tar -cvf'" >>~/.bash_aliases
echo "${green}  Added QOL Aliases
${normal}"

sudo echo "" >>~/.bash_aliases
sudo echo "# Remove a directory and all files" >>~/.bash_aliases
sudo echo "alias rmd='rm  --recursive --force --verbose '" >>~/.bash_aliases
echo "${green}  Added rmd (Remove Directory & Files) Alias
${normal}"

sudo echo "" >>~/.bash_aliases
sudo echo "# Edit this file" >>~/.bash_aliases
sudo echo "alias ba='nano ~/.bash_aliases'" >>~/.bash_aliases
echo "${green}  Added ba Alias (edit bash_aliases file)
${normal}"

sudo echo "" >>~/.bash_aliases
sudo echo "# Aliases for safe and forced reboots" >>~/.bash_aliases
sudo echo "alias rebootsafe='sudo shutdown -r now'" >>~/.bash_aliases
sudo echo "alias rebootforce='sudo shutdown -r -n now'" >>~/.bash_aliases
echo "${green}  Added Reboot Aliases
${normal}"

sudo echo "" >>~/.bash_aliases
sudo echo "# youtube-dl" >>~/.bash_aliases
sudo echo "alias yta-aac='yt-dlp --extract-audio --audio-format aac '" >>~/.bash_aliases
sudo echo "alias yta-best='yt-dlp --extract-audio --audio-format best '" >>~/.bash_aliases
sudo echo "alias yta-flac='yt-dlp --extract-audio --audio-format flac '" >>~/.bash_aliases
sudo echo "alias yta-m4a='yt-dlp --extract-audio --audio-format m4a '" >>~/.bash_aliases
sudo echo "alias yta-mp3='yt-dlp --extract-audio --audio-format mp3 '" >>~/.bash_aliases
sudo echo "alias yta-opus='yt-dlp --extract-audio --audio-format opus '" >>~/.bash_aliases
sudo echo "alias yta-vorbis='yt-dlp --extract-audio --audio-format vorbis '" >>~/.bash_aliases
sudo echo "alias yta-wav='yt-dlp --extract-audio --audio-format wav '" >>~/.bash_aliases
sudo echo "alias ytv-best='yt-dlp -f bestvideo bestaudio '" >>~/.bash_aliases
echo "${green}  Added yt-dlp Aliases
${normal}"

sudo echo "" >>~/.bash_aliases
sudo echo "# GIT" >>~/.bash_aliases
sudo echo "alias gs='git status'" >>~/.bash_aliases
sudo echo "alias ga='git add'" >>~/.bash_aliases
sudo echo "alias gaa='git add --all'" >>~/.bash_aliases
sudo echo "alias gp='git push'" >>~/.bash_aliases
sudo echo "alias gc='git commit'" >>~/.bash_aliases
sudo echo "alias gb='git checkout -b' # Create a new Git branch and move to the new branch at the same time" >>~/.bash_aliases
sudo echo "alias gd='git diff'" >>~/.bash_aliases
echo "${green}  Added Git Aliases
${normal}"

sudo echo "" >>~/.bashrc
sudo echo "# Add fastfetch to bash start" >>~/.bashrc
sudo echo "fastfetch" >>~/.bashrc
echo "${green}  Added fastfetch to bash start
${normal}"

echo "${green}  Completed Creating Aliases.
${normal}"
#Pausing so user can see output
sleep 2

echo "${yellow}  
##############################################
#              Cleanup Section               #
##############################################
${normal}"
sudo apt-get -y autoclean && sudo apt-get -y clean
echo "${green}  Cleaned!.
${normal}"
#Pausing so user can see output
sleep 2

#reload .bashrc and .bash_aliases
source ~/.bashrc
source ~/.bash_aliases
sleep 2

#Explain what was done
echo "${green}
##############################################
#               Overview Section             #
##############################################
Description of what was done:
1. Ensured a non-root user is set up.
2. Ensured non-root user also has sudo permission.
3. Installed Updates, Aliases & Standard Software
4. Ensured SSH is allowed.
5. Ensured ufw firewall is enabled.
6. Locked down SSH if you chose y for that step.
   a. Set SSH not to display banner
   b. Disabled all forwarding
   c. Disabled root login over SSH
   d. Ignoring rhosts
7. Installed fail2ban and configured it to protect SSH.
${normal}"
