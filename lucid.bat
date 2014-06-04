SET meshr=%~dp0
set meshr=%meshr:~0,-1%

set LD_LIBRARY_PATH="%meshr%\usr\lib:$LD_LIBRARY_PATH"
set PATH=%meshr%\bin;%meshr%\usr\bin;%meshr%;%PATH%
set LUA_PATH="%meshr%\usr\lib\lua\?.lua;%meshr%\usr\lib\lua\?\init.lua;;"
set LUA_CPATH="%meshr%\usr\lib\lua\?.so;;"
set LUCI_SYSROOT="%meshr%"
SET meshr=%meshr:\=/%
"%meshr%/bin/rm -rf %meshr%/tmp/.uci
"%meshr%/bin/rm -rf %meshr%/var/run/*
"%meshr%/bin/uci commit
rem call %meshr%/update.bat

:loop
"%meshr%/bin/lua.exe" - < %meshr%/lucid.lua
goto loop
