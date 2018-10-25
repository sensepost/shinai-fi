# shinai-fi - Practise wifi hacking without the hardware

## Prerequisites

On your docker host:
```
modprobe mac80211_hwsim
```

If you're running docker-ce on macOS or Windows, the fake docker host doesn't have kernel support for wifi, rather run your docker host in a VM. If you do want to make your docker-ce work with a custom kernel, check [this article](https://medium.com/@notsinge/making-your-own-linuxkit-with-docker-for-mac-5c1234170fb1).

## Get it

Pull it from docker hub.
```
docker pull singelet/shinai-fi:latest
```
or build the container yourself
```
docker build -t shinari-fi .
```

## Run it

```
docker run -it --privileged --network host singelet/shinai-fi:latest
```

## Use it

Try some wifi hacking, e.g.:

```
airmon-ng start wlan0
airodump-ng wlan0
```

You can also set up a mana rogue AP and see a client connect.
