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
  git remote set-url origin https://github.com/meshr-net/meshr_win32.git
  git commit -am "%USERNAME%.%USERDOMAIN% %DATE% %TIME%"
  git pull origin release < NUL > tmp\git.log || (
      grep "fatal: unable to access" tmp\git.log  && goto :ipkg
      grep "." tmp\git.log || goto :ipkg
      git fetch origin release
      rem SSL certificate problem: unable to get local issuer certificate
      git config http.sslVerify false
      type %meshr:/=\%\.git\index.lock && (del %meshr:/=\%\.git\index.lock || goto :end)
      git reset --merge  < NUL
      tar cf tmp/backup.tar --exclude-vcs --ignore-failed-read  --ignore-command-error -X etc/tarignore etc/* bin/DualServer.ini bin/BluetoothView.cfg 
      bin\git reset --hard origin/release < NUL || ( sudo cmd /c %meshr:/=\%\bin\services.bat stop
        sudo -b cmd /c "cd %meshr% && bin\git reset --hard origin/release < NUL"
        sleep 9 )
      sudo tar xf tmp/backup.tar  -C . --overwrite --ignore-failed-read  --ignore-command-error
      sudo cmd /c %meshr:/=\%\bin\services.bat start
    )
)
:ipkg
call ipkg.bat -force-defaults  update  'meshr' && call ipkg.bat -force-defaults  upgrade  'meshr-update'
:end
