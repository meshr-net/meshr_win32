cd %~dp0..
set meshr=%CD:\=/%
set PATH=%PATH%;%CD%\bin
cd tmp

if exist mguid.txt for /f "tokens=2,*" %%a in ('type mguid.txt ^| find "MachineGuid"') do set KEY_NAME=%%b
if not "%KEY_NAME%"=="" goto :jmp1
set KEY_REGKEY=HKLM\SOFTWARE\Microsoft\Cryptography
set KEY_REGVAL=MachineGuid
set KEY_NAME=
reg query %KEY_REGKEY% /v %KEY_REGVAL% 2>nul || goto :jmp1
for /f "tokens=2,*" %%a in ('reg query %KEY_REGKEY% /v %KEY_REGVAL% ^| findstr %KEY_REGVAL%') do set KEY_NAME=%%b
:jmp1
for /f "tokens=*" %%f in ('type %meshr:/=\%\etc\wifi.txt') do set "%%f"
if not "%MACAddress%"=="" goto :jmp2
if "%guid%"=="" for /f "tokens=*" %%f in ('type %meshr:/=\%\etc\wifi.txt') do set "%%f"
wmic nicconfig where SettingID="{%guid%}" get MACAddress /value | find "=" >> %meshr:/=\%\etc\wifi.txt
for /f "tokens=*" %%f in ('type %meshr:/=\%\etc\wifi.txt ^| find "MACAddress"') do set "%%f"
:jmp2
echo  -%MACAddress%-
if "%KEY_NAME%"=="" set KEY_NAME=.%guid%
BluetoothView.exe /stext bt.txt
WirelessNetConsole.exe > bssids.txt
rem get wifi peers list
for /f "tokens=2* delims=:" %%f in ('ipconfig ^| grep -v "IP.*10.177.254" ^| grep "IP.*10.177."') do ( 
  arp -a -N %%f > arp.txt
  for /f "tokens=1,* delims= " %%f in ('grep "^ *10.177.*-" arp.txt ^| grep -v "10.177.255.255"') do (
    ( ping -n 1 %%f || ping -n 1 %%f || ping -n 1 %%f ) && echo %%f UP >> arp.txt || echo %%f DOWN >> arp.txt
  ) 
)
netsh interface ip delete arpcache

tar -cf up.tar bt.txt arp.txt plink.log bssids.txt ../etc/config/system ../etc/config/freifunk ../tmp/myip --ignore-failed-read  --ignore-command-error
gzip -fc up.tar > up.taz
if exist %meshr:/=\%\bin\openssl\openssl.exe ( move /Y up.taz up.tar
  %meshr:/=\%\bin\openssl\openssl smime -encrypt -binary -aes-256-cbc -in up.tar -out up.taz -outform DER %meshr:/=\%\bin\openssl\meshr-cert.pem  )
for /f "tokens=*" %%f in ('type %meshr:/=\%\bin\DualServer.ini ^| find "10.177." ^| head -n 1') do set IPAddress=%%f
curl -m 20 -s -k -d "slot1=%MACAddress::=-%_%KEY_NAME%&slot2=%IPAddress%" --data-binary @up.taz http://www.meshr.net/post.php -o %meshr%/tmp/curl.htm

for /f "tokens=*" %%f in ('type %meshr:/=\%\tmp\curl.htm ^| head -n 1 ^| grep -E "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"') do set newIP=%%f
if not "%newIP%"=="" (
      if not "%IPAddress%"=="" if not "%newIP%"=="%IPAddress%" sed -i "s/%IPAddress%/%newIP%/g" %meshr%/bin/DualServer.ini
      sed -i "s/IPAddress=.*/IPAddress=%newIP%/g" %meshr%/etc/wlan/meshr.net.txt
      chmod 777 %meshr%/etc/wlan/meshr.net.txt
)
if not "%newIP%"=="" set IPAddress=%newIP%
cd ..
