cd %~dp0..
SET meshr=%CD:\=/%
SETX meshr %meshr% 
rem check admin rights
net session >nul 2>&1 || ( 
  bin\sudo /b /c %0 %*
  goto :EOF
)
for /f "tokens=*" %%f in ('type etc\wifi.txt') do set "%%f"
bin\wlan dc %guid%
if exist var\run\wifi.txt cmd /c bin\services.bat stop "" conn
del var\run\wifi.txt var\run\wifi-formed.txt
for /f "tokens=*" %%f in ('type etc\wlan\%ssid%.txt') do set "%%f"
bin\wlan conn %guid% %ssid% %mode% %ssid%-adhoc > tmp\conn.log 
( type tmp\conn.log  | find "is not correct" ) && bin\wlan conn %guid% %ssid% %mode% %ssid% >> tmp\conn.log
echo %ssid%>var\run\wifi-formed.txt
bin\sleep 3
rem infinite loop
:BOF
if "%ssid%"=="" IF NOT EXIST  etc\wifi.txt goto :CONTINUE
if "%ssid%"=="" for /f "tokens=*" %%f in ('type etc\wifi.txt') do set "%%f"
bin\wlan qi %guid% > %meshr%/tmp/wlan.log
( type tmp\wlan.log  | find """off""" ) && goto :CONTINUE
( type tmp\wlan.log  | find "Got error" ) && goto :CONTINUE
rem trying to connect
IF NOT EXIST  var\run\wifi.txt (
  ( type tmp\wlan.log  | find "formed %ssid%" ) && goto :CONTINUE
  rem disconnected : trying to connect
  ( type tmp\wlan.log  | find """disconnected""" ) && (
    bin\ufind var\run\wifi-formed.txt -mmin +15 | find "wifi" && del var\run\wifi-formed.txt
    bin\ufind var\run\wifi-formed.txt -mmin +2 | find "wifi" && goto :CONTINUE
    bin\wlan conn %guid% %ssid% %mode% %ssid%-adhoc > tmp\conn.log 
    ( type tmp\conn.log  | find "is not correct" ) && bin\wlan conn %guid% %ssid% %mode% %ssid% > tmp\conn2.log
    ( type tmp\conn.log  | find "completed successfully" ) &&  echo %ssid%>var\run\wifi-formed.txt
    goto :CONTINUE )
  rem connecting to meshr.net
  ( type tmp\wlan.log  | find "connected to %ssid%" ) && (
    wmic nicconfig where SettingID="{%guid%}" get DHCPEnabled,DNSServerSearchOrder,DefaultIPGateway,IPAddress,IPSubnet,Caption,DHCPServer /value | more | bin\sed "s/[""{}]//g" | bin\sed "s/^\(IP.*=\)[0-9\.]\+,\([0-9\.]\+\)/\1\2/g" > var\run\wifi.txt
    call lib\setip.bat "%meshr:/=\%\etc\wlan\%ssid%.txt" > tmp\setip.log
    type tmp\setip.log | bin\tr '[\000-\011\013-\037\177-\377]' '.' | bin\grep "^.\?HOST ONLINE" && goto :online
    start %meshr%/lib/tor-tun.bat ^> tmp\tt.log
    bin\start-stop-daemon.exe start meshr-splash
    goto :CONTINUE
:online
    bin\start-stop-daemon.exe start meshr-splash
    start bin\tor.exe --defaults-torrc "%meshr:/=\%\etc\Tor\torrc-defaults" -f "%meshr:/=\%\etc\Tor\torrc" DataDirectory "%meshr:/=\%\etc\Tor" GeoIPFile "%meshr:/=\%\etc\Tor\geoip"
  ) || del var\run\wifi-formed.txt
) ELSE (
  ( type tmp\wlan.log | find "connected to %ssid% " ) && goto :CONTINUE
  rem disconnected: restore old settings in separate console
  cmd /c bin\services.bat stop "" conn
) 
:CONTINUE
bin\sleep 10
goto BOF

rem >bin\..\tmp\wd1.%TIME::=.%.log 2>&1
