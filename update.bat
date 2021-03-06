rem <<BATFILE
rem update linux from win32
if not exist %~dp0\bin\git.exe if not exist %~dp0\..\bin\git.exe if exist c:\MinGW\msys\1.0\bin\sh.exe (
  set PATH=%PATH%;c:\MinGW\bin\;c:\MinGW\msys\1.0\bin\
  copy "%0" %~dp0\tmp\update-tmp.bat 
  c:\MinGW\msys\1.0\bin\sh.exe %cd:\=/%/tmp/update-tmp.bat %*
  exit
)
rem check admin rights
net session >nul 2>&1 || (
  rem echo %1 | find ":" && %~dp0\bin\sudo /c %0 %* || %~dp0\bin\sudo /b /c %0 %*
  %~dp0\bin\sudo /c %0 %*
  goto :EOF
)
if not "%~n0"=="update-tmp.bat" ( copy "%0" %~dp0\tmp\update-tmp.bat && %~dp0\tmp\update-tmp.bat %* && goto :EOF )
set PATH=%meshr:/=\%\bin;%meshr:/=\%\usr\bin;%PATH%
cd %meshr:/=\%
echo  %DATE% %TIME%
set t=%TIME: =%
set tar="tmp\push_%t::=.%.tar"
set backup="tmp/backup_%t::=.%.tar"
git status | find "modified:" && git status | grep -e "modified:" | cut -c 14- | tar cf %tar% -v -T - --exclude=www/*.exe --exclude=bin/DualServer.* --exclude=bin/BluetoothView.cfg --ignore-failed-read  --ignore-command-error
IF "%1"=="" IF EXIST  push.bat tar --list --file %tar% | grep "." && goto :EOF
IF exist %meshr:/=\%\.git\index.lock ( wmic process where ExecutablePath='%meshr:/=\\%\\bin\\git.exe' delete && del %meshr:/=\%\.git\index.lock )
set branch=release
IF "%1"=="m" ( set branch=master && goto :reset )
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
      call :reset
    )
)
:ipkg
Quiet start-stop-daemon.exe start meshr-watchdog
call ipkg.bat -force-defaults  update  'meshr' && call ipkg.bat -force-defaults  upgrade  'meshr-update'
goto :EOF

:reset
git fetch origin %branch% | find "fatal: unable to access" && goto :ipkg
git reset --merge  < NUL
tar cf %backup% --exclude-vcs --ignore-failed-read  --ignore-command-error -X etc/tarignore etc/* var/etc/* bin/DualServer.ini bin/BluetoothView.cfg 
git reset --hard origin/%branch% < NUL || ( 
  call bin\services.bat stop "" update
  git reset  --hard  origin/%branch% < NUL
  ::sleep 9
  tar xf %backup%  -C . --ignore-failed-read  --ignore-command-error
  call bin\services.bat start "" update
  goto :ipkg
)
tar xf %backup%  -C . --ignore-failed-read  --ignore-command-error
git add . -u
goto :EOF
BATFILE


set -x
# check admin rights
if [ `whoami` != 'root' ] && [[ `uname` != MINGW* ]];then
  sudo $0 $@ && exit
fi
[ `basename $0` == update-tmp.bat ] && cd `dirname $0`/.. || cd `dirname $0`
tar --help 2>&1 | grep -q ignore-failed-read && ( tar_extra="--exclude=www/*.exe --ignore-failed-read  --ignore-command-error"
  tar_extra2="--exclude-vcs --ignore-failed-read  --ignore-command-error"
  tar_extra3="--ignore-failed-read  --ignore-command-error" )

git_reset(){
  git fetch origin $branch | grep "fatal: unable to access" && return 1 
  git reset --merge  < /dev/null
  tar cf $backup $tar_extra2 -X etc/tarignore etc/* var/etc/*
  git reset --hard origin/$branch < /dev/null || ( 
    git reset  --hard  origin/$branch < /dev/null
    sleep 1
    tar xf $backup  -C . $tar_extra3
    return 0
  )
  tar xf $backup  -C . $tar_extra3
  git add . -u
}

[ -z $meshr ] && meshr=`pwd`
PATH=$meshr/bin:$PATH
t=$(date +%H%M%S-%d.%m.%Y)
tar="tmp/push_$t.tar"
backup="tmp/backup_$t.tar"
nvram 2>&1 | grep -q "setfile" && ( meshr_backup="`tar czf - $tar_extra2 -X etc/tarignore etc/* var/etc/* | openssl enc -base64 | tr '\n' ' '`"
  [ -n "$meshr_backup" ] && nvram set meshr_backup="$meshr_backup" && nvram commit )
git status | grep "modified:" && git status | grep -e "modified:" | cut -c 14- | tar cf $tar -v -T - $tar_extra
[ "$1" == "" ] && [ -f ./push.bat ] && tar -t -f $tar | grep "." && exit
[ -f $meshr/.git/index.lock ] && killall git
branch=release
[ "$1" == "master" -o "$1" == "m" ] && branch=master && git_reset && exit
git pull origin $branch < /dev/null || ( 
  git config user.email "user@meshr.net"  
  [[ `uname` != MINGW* ]] && git config user.name "$USERNAME $USERDOMAIN"  
  git config --unset http.proxy
  # SSL certificate problem: unable to get local issuer certificate
  git config http.sslVerify false
  git remote set-url origin https://github.com/meshr-net/meshr_tomato-RT-N.git
  git reset --merge  < /dev/null
  git commit -am "$USERNAME.$USERDOMAIN $(date +%H:%M:%S-%d.%m.%Y)"
  git pull origin $branch < /dev/null > tmp/git.log 2>&1 || (
    grep "fatal: unable to access" tmp/git.log  || (
      grep "." tmp/git.log && git_reset && exit
)))
ipkg -force-defaults  update  'meshr' && ipkg -force-defaults  upgrade  'meshr-update'