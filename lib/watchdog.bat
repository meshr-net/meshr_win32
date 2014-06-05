cd %~dp0..
SET meshr=%CD:\=/%
SETX meshr %meshr% 
Set bin=%meshr:/=\%\bin
rem check admin rights
net session >nul 2>&1 || ( 
  %bin%\sudo /b /c %0 %*
  goto :EOF
)
del %meshr:/=\%\var\run\wifi.txt %meshr:/=\%\var\run\wifi-formed.txt
for /f "tokens=*" %%f in ('type %meshr:/=\%\etc\wifi.txt') do set "%%f"
for /f "tokens=*" %%f in ('type %meshr:/=\%\etc\wlan\%ssid%.wmic') do set "%%f"
set IPAddress=%IPAddress:{=%
set IPAddress=%IPAddress:}=%
set IPAddress=%IPAddress:"=%
%bin%\wlan conn %guid% %ssid% %mode% %ssid%-adhoc || %bin%\wlan conn %guid% %ssid% %mode% %ssid%
echo %ssid%>%meshr:/=\%\var\run\wifi-formed.txt
bin\sleep 3
rem infinite loop
:BOF
IF NOT defined ssid IF NOT EXIST  %meshr:/=\%\etc\wifi.txt goto :CONTINUE
IF NOT defined ssid for /f "tokens=*" %%f in ('type %meshr:/=\%\etc\wifi.txt') do set "%%f"
%bin%\wlan qi %guid% > %meshr%/tmp/wlan.log
( type tmp\wlan.log  | find """off""" ) && goto :CONTINUE
( type tmp\wlan.log  | find "Got error" ) && goto :CONTINUE
rem trying to connect
IF NOT EXIST  %meshr:/=\%\var\run\wifi.txt (
  ( type tmp\wlan.log  | find "formed %ssid%" ) && goto :CONTINUE
  rem disconnected : trying to connect
  ( type tmp\wlan.log  | find """disconnected""" ) && (
    %bin%\ufind %meshr:/=\%\var\run\wifi-formed.txt -mmin +15 | find "wifi" && del %meshr:/=\%\var\run\wifi-formed.txt
    %bin%\ufind %meshr:/=\%\var\run\wifi-formed.txt -mmin +2 | find "wifi" && goto :CONTINUE
    %bin%\wlan conn %guid% %ssid% %mode% %ssid%-adhoc > tmp\conn.log 
    ( type tmp\conn.log  | find "is not correct" ) && %bin%\wlan conn %guid% %ssid% %mode% %ssid% >> tmp\conn.log
    ( type tmp\conn.log  | find "completed successfully" ) &&  echo %ssid%>%meshr:/=\%\var\run\wifi-formed.txt
    goto :CONTINUE )
  rem connecting to meshr.net
  ( type tmp\wlan.log  | find "connected to %ssid%" ) && (
    wmic nicconfig where SettingID="{%guid%}" get DHCPEnabled,DNSServerSearchOrder,DefaultIPGateway,IPAddress,IPSubnet,Caption,DHCPServer /value | more > %meshr:/=\%\var\run\wifi.txt
    rem run DHCP server ASAP
    if defined IPAddress if defined NetConnectionID ( netsh interface ip set address %NetConnectionID% static %IPAddress% %IPSubnet:}=% %DefaultIPGateway:}=%
      %bin%\sleep 2
      start %bin%\DualServer.exe -v )
    for %%A in (olsrd) do %bin%\start-stop-daemon.exe stop %%A
    call %meshr:/=\%\lib\setip.bat "%meshr:/=\%\etc\wlan\%ssid%.wmic" > %meshr:/=\%\tmp\setip.log
    type %meshr:/=\%\tmp\setip.log | %bin%\tr '[\000-\011\013-\037\177-\377]' '.' | %bin%\grep "^.\?PC ONLINE" && goto :online
    start %meshr%/lib/tor-tun.bat ^> %meshr:/=\%\tmp\tt.log
    %bin%\start-stop-daemon.exe start meshr-splash
    goto :CONTINUE
:online
    %bin%\start-stop-daemon.exe start meshr-splash
    start %bin%\tor.exe --defaults-torrc "%meshr:/=\%\etc\Tor\torrc-defaults" -f "%meshr:/=\%\etc\Tor\torrc" DataDirectory "%meshr:/=\%\etc\Tor" GeoIPFile "%meshr:/=\%\etc\Tor\geoip"
  ) || del %meshr:/=\%\var\run\wifi-formed.txt
) ELSE (
  ( type %meshr:/=\%\tmp\wlan.log | find "connected to %ssid% " ) && goto :CONTINUE
  rem disconnected: restore old settings
  call %bin%\services.bat stop "" conn
)
:CONTINUE
%bin%\sleep 10
goto BOF

rem >%bin%\..\tmp\wd1.%TIME::=.%.log 2>&1
