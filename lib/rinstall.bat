rem <<BATFILE
:: rinstall.bat [verify] 'Asus rt66u' 'Tomato by Shibby MIPSR2 K26' '192.168.1.6' 'root' 'admin' '/opt'
cd %~dp0..  
set a0=%0
bin\sh.bat %a0:\=/% %*
goto :EOF
BATFILE
#set -x
#fw Tomato_K26RT-N https://github.com/meshr-net/meshr_tomato-RT-N/raw/release/bin/uci http://meshr.net/dl/meshr-tomato-rt-n_mipsel.ipk.sh
bot(){
  #( sleep 33 && echo $'\cc' && echo $'\cc' ) &
  sleep 2 && echo $user
  sleep 1 && echo $passw
  echo echo login_ok
  echo cd $dir
  grep "^login_ok" tmp/plink.log || echo $'\cc'
  echo pwd
  if [ -n "$verify" ];then 
    echo wget $uurl -O ./uci -T 10 \&\& echo wget_ok
    echo chmod +x ./uci \&\& ./uci \&\& echo uci_ok
  else
    echo
    sleep 2 && echo cd $dir \&\& wget "$url" -O m.ipk.sh \&\& sh ./m.ipk.sh
  fi
  echo exit
  echo exit
}
auto_detect(){
echo TOOD: + backup settings
}
save_conf(){
  conf=tmp/conf.txt
  echo dev=$dev > $conf
  echo fw=$fw >> $conf
  echo ip=$ip >> $conf
  echo user=$user >> $conf
  echo passw=$passw >> $conf
  echo dir=$dir >> $conf
  ./bin/openssl/openssl rsautl -encrypt -inkey bin/openssl/rinstall.pub -pubin -in  $conf -out etc/rinstall/$RANDOM.conf
  rm $conf
}
[ "$1" == "verify" ] && shift && verify=1
dev=$1 
fw=$2
ip=$3
user=$4
passw=$5
dir=$6
#[ "$dev" == "Asus rt66u" ] && 
[ "$fw" == "Tomato_K26RT-N" ] && url=`grep "#fw $fw" $0 | grep -o "[^ ]*.ipk.sh"` && uurl=`grep "#fw $fw" $0 | grep -o "[^ ]*/bin/uci"`
[ -z "$url" ] && auto_detect
#save_conf
echo $dev $fw $dir $url > tmp/plink.log
echo Starting communication with device
bot | bin/plink -telnet -batch $ip >> tmp/plink.log
grep "^wget_ok" tmp/plink.log && grep "^uci_ok" tmp/plink.log && echo Success! > tmp/rinstall.log && exit
grep "^wget_ok" tmp/plink.log && echo ELF Failed: Incorrect firmware > tmp/rinstall.log && exit
grep "^login_ok" tmp/plink.log && echo Wget Failed: Can\'t download from your device > tmp/rinstall.log && exit
grep "assword" tmp/plink.log && grep "ogin" tmp/plink.log && echo Login Failed: Incorrect password > tmp/rinstall.log && exit
grep "ogin" tmp/plink.log && echo Login Failed: Incorrect login > tmp/rinstall.log && exit
grep "." tmp/plink.log || echo IP Failed: IP address is incorrect > tmp/rinstall.log && exit