rem check admin rights
net session >nul 2>&1 || (
  rem echo %1 | find ":" && %~dp0\bin\sudo /c %0 %* || %~dp0\bin\sudo /b /c %0 %*
  %~dp0\bin\sudo /c %0 %*
  goto :EOF
)

SET mpath=%CD:\=/%
if "%1"=="" goto blank
if "%1"=="postinst" goto postinst
if "%1"=="Uninstall" (
    ( type %mpath%\tmp\wlan.log | find "connected to meshr.net " ) && call %mpath%\lib\setip.bat %mpath%\var\run\wifi.txt 
    call %~dp0\bin\services.bat stop 
    call %~dp0\bin\services.bat remove confirm
    cd %~dp0
    bin\chmod.exe 777 .\etc\wlan\meshr.net.wmic
    del .\var\etc\olsrd.conf .\bin\DualServer.ini .\etc\wlan\meshr.net.wmic
    move /Y .\etc\wlan\meshr.net.wmic %TEMP%\wmic.%TIME::=.%.tmp
    rm -rf %~dp0
    exit
  ) 2>&1 >> %TEMP%\meshr-Uninstall.log
SET mpath=%1
SET mpath=%mpath:\=/%
SET mpath=%mpath:"=%
:blank
bin\setx meshr %mpath% && set meshr=%mpath%
wmic ENVIRONMENT CREATE NAME="meshr", VARIABLEVALUE="%meshr%" , username="NT AUTHORITY\SYSTEM" || wmic ENVIRONMENT SET NAME="meshr", VARIABLEVALUE="%meshr%" , username="NT AUTHORITY\SYSTEM"

wmic nic where "Name like 'TAP-Win%%'" get NetConnectionID /value | find "=" || start "Installing TAP/TUN adapter" %CD%\bin\tap-windows.exe /S /SELECT_UTILITIES=1

bin\git clone -b release meshr.bundle %1 || ( echo "can't clone"
  bin\git clone -b release meshr.bundle
  call bin\services.bat stop
  copy /Y "%mpath:/=\%\etc\config\*" meshr\etc\config
  xcopy /Y /C /E /H meshr %mpath:/=\%\ )

del meshr.bundle
if not "%1"==""  copy /Y * %mpath:/=\%
cd %mpath:/=\%
set PATH=%meshr:/=\%\bin;%meshr:/=\%\usr\bin;%PATH%

git config user.email "user@meshr.net"
git config user.name "%USERNAME: =_% %USERDOMAIN%"
git remote set-url origin https://github.com/meshr-net/meshr_win32.git
git rm . -r --cached && bin\git add . 
cd %meshr:/=\%\etc\config
git ls-files | tr '\n' ' ' | xargs git update-index --assume-unchanged 
cd %meshr:/=\%
git reset --hard origin/release
call lib\bssids.bat %meshr% > tmp\bssids.log
wlan sp %guid% etc/wlan/meshr.net.xml
touch -am %meshr%/usr/lib/ipkg/lists/meshr

:postinst
call %mpath:/=\%\bin\services.bat stop
call %mpath:/=\%\bin\services.bat remove confirm 

start-stop-daemon.exe install olsrd "%meshr%/usr/sbin/olsrd.exe" -f "%meshr%/var/etc/olsrd.conf"
start-stop-daemon.exe install meshr "%meshr%/lucid.bat"
start-stop-daemon.exe install meshr-splash "%meshr%/lucid-splash.bat"
start-stop-daemon.exe install meshr-watchdog "%meshr%/lib/watchdog.bat"
start-stop-daemon.exe set olsrd start SERVICE_DEMAND_START
start-stop-daemon.exe set meshr-splash start SERVICE_DEMAND_START

netsh advfirewall firewall add rule name="olsrd" dir=in action=allow program="%cd%\usr\sbin\olsrd.exe" enable=yes || netsh firewall add allowedprogram %cd%\usr\sbin\olsrd.exe "olsrd" ENABLE
netsh advfirewall firewall add rule name="meshr tor" dir=in action=allow program="%cd%\bin\tor.exe" enable=yes || netsh firewall add allowedprogram %cd%\bin\tor.exe "meshr tor" ENABLE
netsh advfirewall firewall add rule name="meshr lua" dir=in action=allow program="%cd%\bin\lua.exe" enable=yes || netsh firewall add allowedprogram %cd%\bin\lua.exe "meshr lua" ENABLE
netsh advfirewall firewall add rule name="meshr DualServer" dir=in action=allow program="%cd%\bin\DualServer.exe" enable=yes || netsh firewall add allowedprogram %cd%\bin\DualServer.exe "meshr DualServer" ENABLE
netsh advfirewall firewall add rule name="meshr DNS2SOCKS" dir=in action=allow program="%cd%\bin\DNS2SOCKS.exe" enable=yes || netsh firewall add allowedprogram %cd%\bin\DNS2SOCKS.exe "meshr DNS2SOCKS" ENABLE
netsh firewall set opmode mode=ENABLE exceptions=enable

start-stop-daemon.exe start meshr
start-stop-daemon.exe start meshr-watchdog
