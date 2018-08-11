#!/bin/bash
conf="/opt/sensepost/etc/wpasup.conf"
pid="/opt/sensepost/pid/wpasup.pid"
dev=wlan0
cdev=wlan1
wpas="/sbin/wpa_supplicant"
iw="/sbin/iw"
ip="/sbin/ip"

for x in 1 2 3 4; do
  pgrep hostapd >/dev/null 2>/dev/null
  if [[ $? == 0 ]]; then
    #hostapd is running, find interface it's on
    dev=$(ls /var/run/hostapd/)
    if [[ $dev == "wlan0"* ]]; then
      cdev="wlan1"
    else   
      cdev="wlan0"
    fi
    if [[ -e /var/run/wpa_supplicant/$cdev ]]; then
      if [[ -e $pid ]]; then
        kill $(cat $pid)
      fi
    fi
    $ip link set $cdev up
    $iw dev $cdev scan ssid AmazonSecure > /tmp/foo 2>/tmp/bar
    $iw dev $cdev scan ssid Home
    $iw dev $cdev scan
    sleep 1
    $wpas -B -P $pid -Dnl80211 -i $cdev -c $conf&
  else   
    #hostapd isn't running, kill wpa_supplicant
    if [[ -e $pid ]]; then
      kill $(cat $pid)
    fi
  fi
  sleep 14
done
