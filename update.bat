rem check admin rights
net session >nul 2>&1 || (
  rem echo %1 | find ":" && %~dp0\bin\sudo /c %0 %* || %~dp0\bin\sudo /b /c %0 %*
  %~dp0\bin\sudo /c %0 %*
  goto :EOF
)

set PATH=%meshr:/=\%\bin;%meshr:/=\%\usr\bin;%PATH%
cd %meshr:/=\%
set GIT_SSL_NO_VERIFY=true
echo  %DATE% %TIME%
set tar="tmp\push_%TIME::=.%.tar"
set backup="tmp/backup_%TIME::=.%.tar"
git status | grep -e "modified:" && git status | grep -e "modified:" | cut -c 14- | tar rf %tar% -v -T - --exclude=www/*.exe --exclude=bin/DualServer.* --exclude=bin/BluetoothView.cfg --ignore-failed-read  --ignore-command-error --overwrite
IF "%1"=="" IF EXIST  push.bat tar --list --file %tar% | grep "." && goto :end
type %meshr:/=\%\.git\index.lock && (del %meshr:/=\%\.git\index.lock || goto :end)
set branch=release
IF "%1"=="master" ( set branch=master && goto :reset )
git pull origin %branch% < NUL || ( 
  git config user.email "user@meshr.net"  
  git config user.name "%USERNAME% %USERDOMAIN%"  
  git config --unset http.proxy
  rem SSL certificate problem: unable to get local issuer certificate
  git config http.sslVerify false
  git remote set-url origin https://github.com/meshr-net/meshr_win32.git
  git reset --merge  < NUL
  git commit -am "%USERNAME%.%USERDOMAIN% %DATE% %TIME%"
  git pull origin %branch% < NUL > tmp\git.log 2>&1 || (
      grep "fatal: unable to access" tmp\git.log  && goto :ipkg
      grep "." tmp\git.log || goto :ipkg
      :reset
      git fetch origin %branch%
      type %meshr:/=\%\.git\index.lock && (del %meshr:/=\%\.git\index.lock || goto :end)
      git reset --merge  < NUL
      tar cf %backup% --exclude-vcs --ignore-failed-read  --ignore-command-error -X etc/tarignore etc/* bin/DualServer.ini bin/BluetoothView.cfg 
      git reset --hard origin/%branch% < NUL || ( 
        call bin\services.bat stop
        git reset  --hard  origin/%branch% < NUL
        sleep 9 )
      tar xf %backup%  -C . --overwrite --ignore-failed-read  --ignore-command-error
      call bin\services.bat start
    )
)
:ipkg
call ipkg.bat -force-defaults  update  'meshr' && call ipkg.bat -force-defaults  upgrade  'meshr-update'
:end
