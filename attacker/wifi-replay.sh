#!/bin/bash
tr="/usr/bin/tcpreplay"
cap="/opt/sensepost/capture/sensepost.cap"
repeat=1000
iw="/sbin/iw"
ip="/sbin/ip"
pkill="/usr/bin/pkill"

for x in 1 2 3 4 5 6; do
  #Iterate through wifi adapters
  for dev in `$ip -o link show|cut -d: -f2|grep wlan`; do
    mode=$($iw dev $dev info|grep type|cut -d\  -f2)
    #Is tcpreplay already running for this adapter
    pgrep -f "tcpreplay -i $dev" >/dev/null 2>/dev/null
    if [[ $? == 1 ]]; then
      #tcpreplay is NOT running
      #Is the device in monitor mode
      if [[ $mode == "monitor" ]]; then 
        #It is, start tcpreplay
        echo Starting tcpreplay on $dev
        $ip link set $dev mtu 1600
        $tr -i $dev -l $repeat $cap&
      else
        #It's not, make sure monitor mode is disabled
        #$ifconfig $dev down
        #$iw dev $dev set type managed
        echo "$dev not in monitor mode, won't start"
      fi
    else
      #tcpreplay IS running
      #Is the device in monitor mode
      #if [[ $dev =~ .*mon$ ]]; then 
      if [[ $mode == "monitor" ]]; then 
        #It is, do nothing
        echo "Already running on $dev, skipping"
      else
        #It's not, kill tcpreplay
        $pkill -f "tcpreplay -i $dev"
        #$ifconfig $dev down
        #$iw dev $dev set type managed
        echo "Killed on $dev"
      fi
    fi
  done
  sleep 10
done
