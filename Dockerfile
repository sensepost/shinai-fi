#FROM alpine:latest as builder
#RUN apk update && apk add \
  #build-base \
  #openssl-dev \
  #libnl3-dev \
  #linux-headers \
  #git \
#&& rm -rf /var/cache/apk/*
FROM kalilinux/kali-linux-docker as builder
RUN apt-get update && apt-get install -y \
  build-essential \
  pkg-config \
  git \
  libnl-genl-3-dev \
  libssl-dev \
&& rm -rf /var/lib/apt/lists/*
WORKDIR /hostapd-mana/
RUN git clone --depth=3 https://github.com/sensepost/hostapd-mana \
&& make -j2 -C hostapd-mana/hostapd

FROM kalilinux/kali-linux-docker
LABEL maintainer="@singe at SensePost <research@sensepost.com>"

RUN apt-get update && apt-get install -y \
  aircrack-ng \
  ca-certificates \
  cron \
  iw \
  pciutils \
  ssl-cert \
  tcpreplay \
  unzip \
  wpasupplicant \
&& rm -rf /var/lib/apt/lists/*

COPY /attacker/*.sh /opt/sensepost/bin/
COPY /caps/wpa-induction.cap /opt/sensepost/capture/sensepost.cap
COPY /attacker/wpasup.conf /opt/sensepost/etc/wpasup.conf

RUN chmod +x /opt/sensepost/bin/wifi-replay.sh \
&& chmod +x /opt/sensepost/bin/client.sh \
&& echo -n \
"* * * * * /opt/sensepost/bin/wifi-replay.sh\n \
* * * * * /opt/sensepost/bin/client.sh\n" > crontab.tmp \
&& crontab -u root crontab.tmp \
&& rm -rf crontab.tmp

COPY --from=builder /hostapd-mana/hostapd-mana/hostapd/hostapd /usr/local/bin/
COPY --from=builder /hostapd-mana/hostapd-mana/hostapd/hostapd_cli /usr/local/bin/
COPY mana /root/mana/
ENV PATH $PATH:/hostapd-mana

CMD /etc/init.d/cron start && /bin/bash
