rem run DHCP server ASAP ^> %meshr:/=\%\tmp\ds.log
if %1=="%meshr:/=\%\etc\wlan\meshr.net.txt" if not "%IPAddress%"=="" if not "%NetConnectionID%"=="" ( netsh interface ip set address "%NetConnectionID%" static %IPAddress% %IPSubnet% %DefaultIPGateway%
  start bin\DualServer.exe -v
  goto :test
) 
cd %~dp0..
set meshr=%CD:\=/%
for /f "tokens=*" %%f in ('type %meshr:/=\%\etc\wifi.txt') do set "%%f"
if not "%NetConnectionID%"=="" goto ok
for /f "tokens=2* delims==" %%a in ('type %meshr:/=\%\var\run\wifi.txt ^| find "Caption="') do for /f "tokens=*" %%f in ('wmic path win32_networkadapter where Caption^="%%a" get NetConnectionID /value ^| find "="') do set "%%f"
if "%NetConnectionID%"=="" goto :EOF
echo NetConnectionID=%NetConnectionID%>> %meshr:/=\%\etc\wifi.txt

:ok
( type %1 | find "DHCPEnabled=TRUE" ) && (
  netsh interface ip set dns "%NetConnectionID%" dhcp    
  wmic nicconfig where SettingID="{%guid%}" get DHCPEnabled /value | find "TRUE" && goto :EOF
  netsh interface ip set address "%NetConnectionID%" dhcp | find "DHCP" && (( type %meshr:/=\%\tmp\wlan.log | find """disconnected""" ) && ( wmic path win32_networkadapter where NetConnectionID="%NetConnectionID%" call disable && wmic path win32_networkadapter where NetConnectionID="%NetConnectionID%" call enable
    netsh interface ip set address "%NetConnectionID%" dhcp ))
  goto :EOF
)

for /f "tokens=*" %%f in ('type %1') do set "%%f"
if not "%IPAddress%"=="" netsh interface ip set address "%NetConnectionID%" static %IPAddress% %IPSubnet% %DefaultIPGateway%
if %1=="%meshr:/=\%\etc\wlan\meshr.net.txt" if not "%IPAddress%"=="" start bin\DualServer.exe -v
echo -%DefaultIPGateway% | find "." || set DefaultIPGateway=""
echo -%DNSServerSearchOrder% | find "." && netsh interface ip set dns "%NetConnectionID%"  static %DNSServerSearchOrder% || netsh interface ip set dns "%NetConnectionID%" dhcp
if "%IPAddress%"=="" netsh interface ip set address "%NetConnectionID%" dhcp
if not %1=="%meshr:/=\%\etc\wlan\meshr.net.txt" goto :EOF

:test
bin\start-stop-daemon.exe stop olsrd
rem test if offline
if not exist %meshr:/=\%\var\etc\olsrd.conf goto :EOF
( bin\curl http://74.125.224.72 -o NUL -m 10 || ( bin\curl http://74.125.224.72 -o NUL -m 10 ) ) && (
  if "%IPAddress%"=="" ( call lib\upload.bat
    netsh interface ip set address "%NetConnectionID%" static %IPAddress% %IPSubnet% %DefaultIPGateway% )
    if not "%IPAddress%"=="" ( type %meshr:/=\%\var\etc\olsrd.conf | find "%IPAddress%" | find "255.255.255.255"  || ( 
    bin\sed -i "s/.*10.177.\+255.255.255.255.*//g" %meshr:/=\%\var\etc\olsrd.conf
    echo Hna4 { %IPAddress% 255.255.255.255 } >> %meshr:/=\%\var\etc\olsrd.conf
  ))  
  bin\sleep 3
  bin\start-stop-daemon.exe start olsrd
  echo HOST ONLINE
  goto :EOF
)
type %meshr:/=\%\var\etc\olsrd.conf | find "%IPAddress%" | find "255.255.255.255" && bin\sed -i "s/.*10.177.\+255.255.255.255.*//g" %meshr:/=\%\var\etc\olsrd.conf
bin\sleep 1
bin\start-stop-daemon.exe start olsrd      
