# CyberPatriot Scripts


This bash script automates the common vulnerabilities found within the Linux portion of the CyberPatriot competition. This script currently goes over automating updates, firewall, auditing, and malware removal.


<details>
<summary><strong>Linux Installation</strong></summary>
<br>

1. Clone the repository

```
git clone https://github.com/Nathan-Kimm/CyberPatriot-Scripts.git
```

2. Navigate to the directory where the script was cloned

```
cd /path/tofile/CyberPatriot-Scripts
```

3. Make the script and config file executable

```
chmod +x Ubuntu.sh

chmod +x Ubuntu.conf
```

4. Run the script

```
./Ubuntu.sh
```

</details>

<details>
<summary><strong>Windows Installation</strong></summary>
<br>

1. After downloading, run the script in admin

> [!NOTE]
> Windows Script is very basic and needs some work

</details>

<details>
<summary><strong>User Auditing</strong></summary>
<br>

* Users listed on the README should be inputted into users.txt
* When script is run, users on the system will be put into currentusers.txt and users that are not found will be printed in user_log.txt

</details>

> [!NOTE]
> Make sure to configure the config file and read the README for the competition before running script