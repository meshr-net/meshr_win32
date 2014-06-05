cd %~dp0..
set meshr=%CD:\=/%
set NetConnectionID=
for /f "tokens=*" %%f in ('type %meshr:/=\%\etc\wifi.txt') do set "%%f"
IF DEFINED  NetConnectionID goto ok
IF NOT DEFINED  NetConnectionID for /f "tokens=2* delims==" %%a in ('type %meshr:/=\%\var\run\wifi.txt ^| find "Caption="') do for /f "tokens=*" %%f in ('wmic path win32_networkadapter where Caption^="%%a" get NetConnectionID /value ^| find "="') do set "%%f"
IF NOT DEFINED  NetConnectionID goto :EOF
set NetConnectionID="%NetConnectionID:"=%"
echo NetConnectionID=%NetConnectionID%>> %meshr:/=\%\etc\wifi.txt

:ok
( type %1 | find "DHCPEnabled=TRUE" ) && (
  wmic nicconfig where SettingID="{%guid%}" get DHCPEnabled /value | find "TRUE" && goto :EOF
  netsh interface ip set address %NetConnectionID% dhcp | find "DHCP" && (( type %meshr:/=\%\tmp\wlan.log | find """disconnected""" ) && ( wmic path win32_networkadapter where NetConnectionID=%NetConnectionID% call disable && wmic path win32_networkadapter where NetConnectionID=%NetConnectionID% call enable
    netsh interface ip set address %NetConnectionID% dhcp ))
  netsh interface ip set dns %NetConnectionID% dhcp    
  goto :EOF
)

for /f "tokens=*" %%f in ('type %1') do set "%%f"

set IPSubnet=%IPSubnet:{=%
set IPAddress=%IPAddress:{=%
set IPAddress=%IPAddress:}=%
set IPAddress=%IPAddress:"=%
set DefaultIPGateway=%DefaultIPGateway:{=%
set DefaultIPGateway=%DefaultIPGateway:"=%}
if defined IPAddress netsh interface ip set address %NetConnectionID% static %IPAddress% %IPSubnet:}=% %DefaultIPGateway:}=%
if %1=="%meshr:/=\%\etc\wlan\meshr.net.wmic" if defined IPAddress start %bin%\DualServer.exe -v

set DNSServerSearchOrder=%DNSServerSearchOrder:{=%

echo %DefaultIPGateway:}=% | find "." || set DefaultIPGateway=}

echo %DNSServerSearchOrder:}=% | find "." && netsh interface ip set dns %NetConnectionID%  static %DNSServerSearchOrder:}=% || netsh interface ip set dns %NetConnectionID% dhcp
if not defined IPAddress netsh interface ip set address %NetConnectionID% dhcp

if not %1=="%meshr:/=\%\etc\wlan\meshr.net.wmic" goto :EOF
Set bin=%meshr:/=\%\bin
rem test if offline
if not exist %meshr:/=\%\var\etc\olsrd.conf goto :EOF
( %bin%\curl http://74.125.224.72 -o NUL -m 10 || ( %bin%\curl http://74.125.224.72 -o NUL -m 10 ) ) && (
  type %meshr:/=\%\var\etc\olsrd.conf | find "%IPAddress%" | find "255.255.255.255"  || ( 
    %bin%\sed -i "s/.*10.177.\+255.255.255.255.*//g" %meshr:/=\%\var\etc\olsrd.conf
    echo Hna4 { %IPAddress% 255.255.255.255 } >> %meshr:/=\%\var\etc\olsrd.conf
  )  
  %bin%\sleep 1
  %bin%\start-stop-daemon.exe start olsrd
  echo PC ONLINE
  goto :EOF
)
type %meshr:/=\%\var\etc\olsrd.conf | find "%IPAddress%" | find "255.255.255.255" && %bin%\sed -i "s/.*10.177.\+255.255.255.255.*//g" %meshr:/=\%\var\etc\olsrd.conf
%bin%\sleep 1
%bin%\start-stop-daemon.exe start olsrd      
