#!/bin/bash

#-y auto confirms without prompting user
#https://devhints.io/bash


#Checks if config file exists
if [ -! -e Ubuntu.conf ]; then
    echo "Config file does not exist. Please install config file before continuing."
    exit 1
fi

#Checks if user has root access
if [[ $EUID -ne 0 ]]; then
    echo "You must be root to run this script."
    exit 1
fi


#Imports Config File
. Ubuntu.conf


if [[ $ENABLE_UPDATES == true ]]; then
    echo "Installing Updates"
    apt-get update
    
    echo "Installing Upgrades"
    apt-get dist-upgrade -y

    echo "Installing Auto Clean"
    apt-get autoclean -y

    echo "Installing Auto Remove"
    apt-get autoremove -y

    echo "Installing Check"
    apt-get check
fi


#https://phoenixnap.com/kb/automatic-security-updates-ubuntu
if [[ $AUTOMATIC_UPDATES == true ]]; then
    echo "Installing Unattended Upgrades"
    apt install unattended-upgrades -y

    echo "Configuring Unattended Upgrades"
    sed -i "s/"

    echo "Enabling Automatic Updates"
    sed -i "s/APT::PERIODIC::Update-Package-Lists \"0\"/APT::PERIODIC::Update-Package-Lists \"1\"/g" /etc/apt/apt.conf.d/20auto-upgrades
    sed -i "s/APT::PERIODIC::Unattended-Upgrade \"0\"/APT::PERIODIC::Unattended-Upgrade \"1\"/g" /etc/apt/apt.conf.d/20auto-upgrades

    echo "Restarting Unattended Upgrades"
    systemctl restart unattended-upgrades.service
fi


if [[ $ENABLE_FIREWALL == true ]]; then
    echo "Installing Uncomplicated Firewall"
    apt-get install ufw -y

    echo "Enabling Firewall, denying incoming, and allowing outgoing"
    ufw enable
    ufw default deny incoming
    ufw defautl allow outgoing
fi


if [[ $ENABLE_AUDITING == true ]]; then
    echo "Installing Auditing Daemon"
    apt-get install auditd -y

    echo "Enabling Auditing"
    auditctl -e 1 > /var/local/audit.log
fi


if [[ $INSTALL_SSH_SERVER == true ]]; then
    echo "Installing OpenSSH Server"
    apt-get install openssh-server -y

    echo "Disabling Root Login"
    sed -i '/^PermitRootLogin/ c\PermitRootLogin no' /etc/ssh/sshd_config
    echo "Restarting Service to Apply Changes"
    service ssh restart
fi


#REVIEW THIS CODE
if [[ $CHANGE_PASSWORD == true ]]; then 
    #CHANGE PASSWORD
    new_password="Cyb3rPatr!0t$"
    users=$(cat /etc/passwd | cut -d ":" -f1)
    for users in $users; do
        usermod --password $(echo $new_password | openssl passwd -1 -stdin) $user
        echo "Changed password for user $user"
    done
fi


if [[ $INSTALL_CLAM == true ]]; then 
    echo "Installing Clam Antivirus"
    apt-get install clamav -y

    echo "Updating Clam"
    freshclam

    echo "Running scan of /home directory"
    clamscan -r /home
fi


if [[ $REMOVE_MALWARE == true ]]; then
    echo "Removing Hydra"
    apt-get purge hydra -y

    echo "Removing John the Ripper"
    apt-get purge john -y

    echo "Removing Nikto"
    apt-get purge nikto -y

    echo "Removing Netcat"
    apt-get purge netcat -y
fi

if [[ $INSTALL_PAM == true ]]; then
    echo "Installing PAM"
    apt-get install libpam-cracklib -y 

    echo "Configuring PAM"
    sed -i '1 s/^/password requisite pam_cracklib.so retry=3 minlen=8 difok=8 dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1\n/' /etc/pam.d/common-password

    echo "Configuring Login"
    sed -i  '/^PASS_MAX_DAYS/ c\PASS_MAX_DAYS   90' /etc/login.defs
    sed -i  '/^PASS_MAX_DAYS/ c\PASS_MIN_DAYS   10' /etc/login.defs
    sed -i  '/^PASS_MAX_DAYS/ c\PASS_WARN_AGE   7' /etc/login.defs
    sed -i  '/^FAILLOG_ENAB/ c\FAILLOG_ENAB YES' /etc/login.defs
    sed -i  '/^LOG_UNKAIL_ENAB/ c\LOG_UNKAIL_ENAB YES' /etc/login.defs
    sed -i  '/^SYSLOG-SU-ENAB/ c\SYSLOG-SU-ENAB YES' /etc/login.defs
    sed -i  '/^SYSLOG-SG-ENAB/ c\SYSLOG-SG-ENAB YES' /etc/login.defs

fi