cd "%meshr:/=\%"
set PATH=%PATH%;%CD%\bin
cd "%meshr:/=\%\tmp"

if exist mguid.txt for /f "tokens=2,*" %%a in ('type mguid.txt ^| find "MachineGuid"') do set KEY_NAME=%%b
if defined KEY_NAME goto :jmp1
set KEY_REGKEY=HKLM\SOFTWARE\Microsoft\Cryptography
set KEY_REGVAL=MachineGuid
set KEY_NAME=
reg query %KEY_REGKEY% /v %KEY_REGVAL% 2>nul || goto :jmp1
for /f "tokens=2,*" %%a in ('reg query %KEY_REGKEY% /v %KEY_REGVAL% ^| findstr %KEY_REGVAL%') do set KEY_NAME=%%b
:jmp1
for /f "tokens=*" %%f in ('type %meshr:/=\%\etc\wifi.txt') do set "%%f"
if defined MACAddress goto :jmp2
wmic nicconfig where SettingID="{%guid%}" get MACAddress /value | find "=" >> %meshr:/=\%\etc\wifi.txt
for /f "tokens=*" %%f in ('type %meshr:/=\%\etc\wifi.txt ^| find "MACAddress"') do set "%%f"
:jmp2
echo  -%MACAddress%-

cd "%meshr:/=\%/tmp"
BluetoothView.exe /stext bt.txt
WirelessNetConsole.exe > bssids.txt
rem get wifi peers list
for /f "tokens=2* delims=:" %%f in ('ipconfig ^| grep -v "IP.*10.177.254" ^| grep "IP.*10.177."') do ( 
  arp -a -N %%f > arp.txt
  for /f "tokens=1,* delims= " %%f in ('grep "^ *10.177.*-" arp.txt ^| grep -v "10.177.255.255"') do (
    ( ping -n 1 %%f || ping -n 1 %%f || ping -n 1 %%f ) && echo %%f >> arp.txt
  ) 
)
netsh interface ip delete arpcache

tar -cf up.tar bt.txt arp.txt bssids.txt ../etc/config/system ../etc/config/freifunk ../tmp/myip --ignore-failed-read  --ignore-command-error
gzip -fc up.tar > up.taz
curl -s -k -d "slot1=%MACAddress::=-%.%KEY_NAME%" --data-binary @up.taz http://meshr.net/post.php -o %meshr%/tmp/curl.htm

for /f "tokens=*" %%f in ('type %meshr:/=\%\tmp\curl.htm ^| head -n 1 ^| grep -E "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"') do set newIP=%%f
for /f "tokens=*" %%f in ('type %meshr:/=\%\bin\DualServer.ini ^| grep -m 1 "10.177."') do set IPAddress=%%f
if defined newIP (
      if defined IPAddress if not "%newIP%"=="%IPAddress%" sed -i "s/%IPAddress%/%newIP%/g" %meshr%/bin/DualServer.ini
      sed -i "s/IPAddress={.*}/IPAddress={""%newIP%""}/g" %meshr%/etc/wlan/meshr.net.wmic
)
cd ..