if not "%1"=="" set meshr=%1
cd "%meshr:/=\%"
copy /y nul .\tmp\bssids.txt > .\tmp\null
type %meshr:/=\%\etc\wifi.txt | find "guid" || for /f "tokens=2 delims= " %%i in ('%meshr:/=\%\bin\wlan ei ^| find "GUID"') do (
  rem default config
  echo guid=%%i>%meshr:/=\%\etc\wifi.txt
  echo mode=adhoc>>%meshr:/=\%\etc\wifi.txt
  echo ssid=meshr.net>>%meshr:/=\%\etc\wifi.txt
)  
for /f "tokens=*" %%f in ('type %meshr:/=\%\etc\wifi.txt') do set "%%f"
if "%guid%"=="" del %meshr:/=\%\etc\wifi.txt
.\bin\wlan gvl %guid% >> .\tmp\bssids.txt && .\bin\wlan gbs %guid% | .\bin\grep -e "MAC\|SSID" >> .\tmp\bssids.txt
type .\tmp\bssids.txt | find "SSID:" || del .\tmp\bssids.txt
