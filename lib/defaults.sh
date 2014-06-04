#!/bin/sh
#set -x
rm -rf $meshr/tmp/.uci/*

#Location auto-config
if [ 1 ]; then
  $meshr/usr/sbin/olsrd.exe -int > $meshr/tmp/olsrd.int
  curl -o - -A Mozilla -m 20 http://www.ip-adress.com/ip_tracer/ > $meshr/tmp/myip
  if [  -f $meshr/tmp/myip ] ; then
    lat=`cat $meshr/tmp/myip | grep 'latLng' | sed 's/.\+ lat: \([^,]\+\).\+/\1/g'`
    lon=`cat $meshr/tmp/myip | grep 'latLng' | sed 's/.\+ lng: \([^ ]\+\).\+/\1/g'`
  fi
  city=`cat $meshr/tmp/myip | grep setInfoContentHTML | sed 's/.\+:<br>\(.\+\) in.\+/\1/g' | grep -v "setInfoContentHTML"`
  echo $city | grep ">"
  myip=`cat $meshr/tmp/myip | grep 'My IP is: [0-9]' | sed 's/.\+My IP is: \([0-9.]\+\).\+/\1/g'`
  if [  -f $meshr/tmp/bssids.txt ] ; then  
    echo { \"wifiAccessPoints\": [> $meshr/tmp/json.txt
    grep "MAC Address.*:.*-" $meshr/tmp/bssids.txt | sed 's/.*:..\(..-..-..-..-..-..\)$/{"macAddress": "\1"},/g' >>$meshr/tmp/json.txt
    echo {\"macAddress\": \"00-00-00-00-00-00\"}]}>>$meshr/tmp/json.txt
    [ -f $meshr/tmp/latlon.txt ]  && rm $meshr/tmp/latlon.txt
    sudo -geoloc
    grep 'lat' $meshr/tmp/latlon.txt  || sudo -geoloc
    if cat $meshr/tmp/latlon.txt | grep 'lat' ; then
      lat=`cat $meshr/tmp/latlon.txt | grep 'lat' | sed 's/.*lat": \([^,]\+\).\+/\1/g'`
      lon=`cat $meshr/tmp/latlon.txt | grep 'lng' | sed 's/.*lng": \([^,]\+\).*/\1/g'`
    fi  
  fi
  uci set system.system.location="$city"
  uci set system.system.latitude="$lat"
  uci set system.system.longitude="$lon"
  uci set system.system.hostname="$USERNAME-$USERDOMAIN"
  uci commit system
  uci set meshwizard.community="community"
  comm=`ls etc/config/profile_* | grep -i "$city" | sed 's/.*_//g'`
  uci commit meshwizard
fi

#Looking for known wifi networks (communities)
if [  -f $meshr/tmp/bssids.txt ] ; then
  #netsh wlan show  networks | grep -e "^SSID" | sed -e "s/.\+ : //g" > $meshr/tmp/wlans.txt
  #netsh wlan show  networks  mode=bssid  > $meshr/tmp/bssids.txt
  grep "^SSID: .\+" $meshr/tmp/bssids.txt | cut -c 7- > $meshr/tmp/wlans.txt
  uci show | grep -e "profile_.*.profile.ssid" | sed -e "s/.\+=//g"  > $meshr/tmp/ssids.txt
  echo meshr.net >> $meshr/tmp/wlans.txt

  for net in $(grep -Fx -f $meshr/tmp/wlans.txt $meshr/tmp/ssids.txt | tr " " "\n")
  do
    comm=`uci show | grep -e "profile_.*=$net" | sed -e "s/profile_\(.*\).profile.ssid=.\+/\1/g"`
  done
fi
[ -z $comm ] && comm=meshr
uci set meshwizard.community.name="$comm"
for ifs in $(cat $meshr/tmp/olsrd.int | grep -e "if[0-9]\+" | sed -e "s/\(if[^:]\+\).\+/\1/g" | tr " " "\n")
do
  uci set network.$ifs="interface"
  uci set network.$ifs.ifname="$ifs"
  uci commit network 
done
filter="."
cat $meshr/tmp/olsrd.int | grep -e "if[0-9]\+" | grep ": $filter " || filter="?"
cat $meshr/tmp/olsrd.int | grep -e "if[0-9]\+" | grep ": $filter " || filter="-"
for ifs in $(cat $meshr/tmp/olsrd.int | grep -e "if[0-9]\+" | grep -m 1 ": + " | sed -e "s/\(if[^:]\+\).\+/\1/g" | tr " " "\n")
do
  uci set meshwizard.netconfig.${ifs}_config=1
  uci set meshwizard.netconfig.${ifs}_ip4addr=$ip4addr
done  
uci commit meshwizard

$meshr/usr/bin/meshwizard/wizard.sh
