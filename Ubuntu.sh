#!/bin/bash

#-y auto confirms without prompting user
#https://devhints.io/bash


#Checks if config file exists
if [ ! -r Ubuntu.conf ]; then
    echo "Config file does not exist. Please install config file before continuing."
    exit 1
fi

#Checks if user has root access
# if [[ $EUID -ne 0 ]]; then
#     echo "You must be root to run this script."
#     exit 1
# fi


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
    sed -i '/"${distro-id}:${distro_codename}";/s/^#/g' /etc/apt/apt.conf.d/50unattented-upgrades
    sed -i '/"${distro-id}:${distro_codename}-security";/s/^#/g' /etc/apt/apt.conf.d/50unattented-upgrades
    

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
    sed -i  's/^PASS_MAX_DAYS*/ c\PASS_MAX_DAYS   90/g' /etc/login.defs
    sed -i  's/^PASS_MAX_DAYS*/ c\PASS_MIN_DAYS   10/g' /etc/login.defs
    sed -i  's/^PASS_MAX_DAYS*/ c\PASS_WARN_AGE   7/g' /etc/login.defs
    sed -i  's/^FAILLOG_ENAB*/ c\FAILLOG_ENAB YES/g' /etc/login.defs
    sed -i  's/^LOG_UNKAIL_ENAB*/ c\LOG_UNKAIL_ENAB YES/g' /etc/login.defs
    sed -i  's/^SYSLOG-SU-ENAB*/ c\SYSLOG-SU-ENAB YES/g' /etc/login.defs
    sed -i  's/^SYSLOG-SG-ENAB*/ c\SYSLOG-SG-ENAB YES/g' /etc/login.defs
fi


if [[ $USER_AUDIT == true ]]; then
    input="currentusers.txt"
    awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd >> currentusers.txt
    while IFS= read -r line; do
        if grep -q "$line" "users.txt"; then

            #NEEDS TESTING TO CHECK IF USER IS ADMIN
            if sudo -l -U "$line" | grep -q "(ALL) ALL"; then
                echo "$line is found and is an admin" >> logs/user_log.txt
            else
                echo "$line is found but not an admin" >> logs/user_log.txt
            fi
        else
            echo "$line was not found (Consider Removing)" >> logs/user_log.txt
        fi
    done < "$input"
fi


if [[ $ACCOUNT_LOCKOUT == true ]]; then
    echo "auth required pam_tally2.so deny=5 onerr=fail unlock_time=1800" >> /etc/pam.d/common-auth
fi


if [[ $ALLOW_GUEST == true ]]; then
    echo "allow-guest=false" >> /etc/lightdm/lightdm.conf
fi


if[[ $CONFIGURE_SYSCTL == true ]]; then
    #work in progress :)
fi


if [[ $LOCATE_MEDIA == true ]]; then
    echo "---------------MEDIA FILES---------------" >> logs/media_log.txt
    locate *.mkv *.webm *.flv *.vob *.ogv *.drc *.gifv *.mng *.avi$ *.mov *.qt *.wmv *.yuv *.rm *.rmvb *.asf *.amv *.mp4$ *.m4v *.mp *.m?v *.svi *.3gp *.flv *.f4v >> logs/media_log.txt
    echo "---------------AUDIO FILES---------------" >> logs/media_log.txt
    locate *.3ga *.aac *.aiff *.amr *.ape *.arf *.asf *.asx *.cda *.dvf *.flac *.gp4 *.gp5 *.gpx *.logic *.m4a *.m4b *.m4p *.midi *.mp3 *.pcm *.rec *.snd *.sng *.uax *.wav *.wma *.wpl *.zab >> logs/media_log.txt
fi


if [[ $LOG_CRON == true ]]; then
    crontab -l >> /logs/cronjob_log.txt
fi


if [[ $LOG_NETSTAT == true ]]; then
    ss -an4 > /logs/netstat_log.txt
fi