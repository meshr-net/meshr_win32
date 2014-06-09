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
set tar="tmp\push%TIME::=.%.tar"
git status | grep -e "modified:" && git status | grep -e "modified:" | cut -c 14- | tar rf %tar% -v -T - --exclude=etc/* --exclude=www/*.exe --exclude=bin/DualServer.* --exclude=bin/BluetoothView.cfg --ignore-failed-read  --ignore-command-error --overwrite
IF "%1"=="" IF EXIST  push.bat tar --list --file %tar% | grep "." && goto :end
type %meshr:/=\%\.git\index.lock && (del %meshr:/=\%\.git\index.lock || goto :end)
git pull origin release < NUL || ( 
  git config user.email "user@meshr.net"  
  git config user.name "%USERNAME% %USERDOMAIN%"  
  git config --unset http.proxy
  rem SSL certificate problem: unable to get local issuer certificate
  git config http.sslVerify false
  git remote set-url origin https://github.com/meshr-net/meshr_win32.git
  git commit -am "%USERNAME%.%USERDOMAIN% %DATE% %TIME%"
  git pull origin release < NUL > tmp\git.log 2>&1 || (
      grep "fatal: unable to access" tmp\git.log  && goto :ipkg
      grep "." tmp\git.log || goto :ipkg
      git fetch origin release
      type %meshr:/=\%\.git\index.lock && (del %meshr:/=\%\.git\index.lock || goto :end)
      git reset --merge  < NUL
      tar cf tmp/backup.tar --exclude-vcs --ignore-failed-read  --ignore-command-error -X etc/tarignore etc/* bin/DualServer.ini bin/BluetoothView.cfg 
      git reset --hard origin/release < NUL || ( 
        call %meshr:/=\%\bin\services.bat stop
        git reset  --hard  origin/release < NUL
        sleep 9 )
      tar xf tmp/backup.tar  -C . --overwrite --ignore-failed-read  --ignore-command-error
      call %meshr:/=\%\bin\services.bat start
    )
)
:ipkg
call ipkg.bat -force-defaults  update  'meshr' && call ipkg.bat -force-defaults  upgrade  'meshr-update'
:end
