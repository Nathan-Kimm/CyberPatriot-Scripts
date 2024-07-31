@echo off

REM Admin and Guest
net user administrator /active:no
net user guest /active:no
REM Firewall
netsh advfirewall set allprofiles state on
REM Telnet
DISM /online /disable-feature /featurename:TelnetClient
DISM /online /disable-feature /featurename:TelnetServer
sc stop "TlntSvr"
sc config "TlntSvr" start= disabled
REM Remote Desktop
sc stop "TermService"
sc config "TermService" start= disabled
sc stop "SessionEnv"
sc config "SessionEnv" start= disabled
sc stop "UmRdpService"
sc config "UmRdpService" start= disabled
sc stop "Remote Registry"
sc config "RemoveRegistry" start= disabled
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 1 /f