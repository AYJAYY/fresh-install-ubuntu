#!/bin/bash

# Defining Colors for text output
red=$( tput setaf 1 );
yellow=$( tput setaf 3 );
green=$( tput setaf 2 );
normal=$( tput sgr 0 );

osName=$( cat /etc/*os-release | grep ^NAME | cut -d '"' -f 2 );

echo "${red}
THIS IS ONLY TO BE USED WITH UBUNTU!
Please Ctrl-C if you are not on Ubuntu, Edubuntu, Kubuntu, Lubuntu, Ubuntu Studio, or Xubuntu.
${normal}"
#Pause so user can see output
sleep 5

# Checking if running as root. If yes, asking to change to a non-root user.
# This verifies that a non-root user is configured and is being used to run
# the script.
if [ ${UID} == 0  ]
then
  echo "${red}
  You're running this script as root user.
  Please configure a non-root user and run this
  script as that non-root user.
  Please do not start the script using sudo, but
  enter sudo privileges when prompted.
  ${normal}"
  #Pause so user can see output
  sleep 1
  exit
fi

echo "${green}  You're running $osName. We will begin applying updates, and securing the system.

You will be prompted for your sudo password.
Please enter it when asked.
${normal}
"

##############################################
#      Update, Install & Secure Section      #
##############################################
echo "${yellow}  Running Updates.
${normal}"
sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get -y dist-upgrade
sudo apt-get -y install sysstat vnstat iotop iftop bwm-ng htop munin flatpak curl ssh
sudo add-apt-repository ppa:zhangsongcui3371/fastfetch
sudo apt-get upgrade
sudo apt-get install fastfetch

echo "${green}  Completed Updates & Installs.
${normal}"
#Pausing so user can see output
sleep 1

echo "${yellow}  Securing SSH Config.
${normal}"
sudo echo "DisableForwarding yes" >> /etc/ssh/sshd_config.d/10-my-sshd-settings.conf
sudo echo "PermitRootLogin no" >> /etc/ssh/sshd_config.d/10-my-sshd-settings.conf
sudo echo "IgnoreRhosts yes" >> /etc/ssh/sshd_config.d/10-my-sshd-settings.conf
echo "${green}  Completed Securing SSH Config.
${normal}"
#Pausing so user can see output
sleep 2


##############################################
#              .bashrc Section               #
##############################################

echo "${yellow}  Creating Aliases & ~/.bashrc
${normal}"
sudo echo "alias updater='sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get -y dist-upgrade'" >> ~/.bashrc
sudo echo "alias ff='fastfetch'" >> ~/.bashrc
sudo echo "alias cd..='cd ..'" >> ~/.bashrc
sudo echo "alias grep='grep --color=auto'" >> ~/.bashrc
sudo echo "alias rm='rm -I --preserve-root'" >> ~/.bashrc
sudo echo "alias chown='chown --preserve-root'" >> ~/.bashrc
sudo echo "alias chmod='chmod --preserve-root'" >> ~/.bashrc
sudo echo "alias chgrp='chgrp --preserve-root'" >> ~/.bashrc
sudo echo "alias wget='wget -c'" >> ~/.bashrc

echo "${green}  Completed Creating Aliases.
${normal}"
#Pausing so user can see output
sleep 2


##############################################
#              Firewall Section              #
##############################################

# Enabling ufw firewall and making sure it allows SSH
echo "${yellow}  Enabling ufw firewall. Ensuring SSH is allowed.
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


##############################################
#          Ubuntu fail2ban Section           #
##############################################

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
fail2ban restarted
${normal}"

# Tell the user what the fail2ban protections are set to
echo "${green}
fail2ban is now protecting SSH with the following settings:
maxretry: 5
findtime: 12 hours (43200 seconds)
bantime: 24 hours (86400 seconds)
${normal}"
# Pausing so user can see output
sleep 2

##############################################
#           Ubuntu Overview Section          #
##############################################
echo "${yellow}  Cleaning Up.
${normal}"
sudo apt-get -y autoclean && sudo apt-get -y clean
echo "${green}  Cleaned!.
${normal}"
#Pausing so user can see output
sleep 1

#Explain what was done
echo "${green}
Description of what was done:
1. Ensured a non-root user is set up.
2. Ensured non-root user also has sudo permission (script won't continue without it).
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
