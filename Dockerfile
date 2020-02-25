# Multi-Stage build to shrink image size

###############################################################################
# Stage 0
###############################################################################
FROM ubuntu:bionic
COPY tmp/ubuntu1804.iso /ubuntu1804.iso
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
     wget \
     p7zip-full \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p \
     /var/breqwatr/pxe/http \
     /var/breqwatr/pxe/tftp \
     /iso \
 && 7z x /ubuntu1804.iso -o/iso \
 && cp -r /iso/install/netboot/ubuntu-installer /var/breqwatr/pxe/tftp/ \
 && cp -r /iso/.disk   /var/breqwatr/pxe/http/ \
 && cp -r /iso/pool    /var/breqwatr/pxe/http/ \
 && cp -r /iso/dists   /var/breqwatr/pxe/http/ \
 && cp -r /iso/install /var/breqwatr/pxe/http/ \
 && cp -r /iso/preseed /var/breqwatr/pxe/http/

# NOTE(Kyle):
# It's absurd, but you also have to fix some broken file paths. Some testing
# they did on this ISO! The paths must have been too long and got mangled. Some
# others are broken too but they don't look needed right now. if NGINX shows
# 404's then fix them too. (Everything after rm -rf /iso)
RUN find /var/breqwatr/pxe/http | grep "\.ude" | grep -v ".\udeb" | while read f; do new=$f"b"; cp $f $new ; done \
 && cd /var/breqwatr/pxe/http/pool/main/l/linux/
# Needed this in 18.04.03, it doesn't seem to be there now
# && cp pcmcia-storage-modules-4.15.0-55-generic-di_4.15.0-55.60_amd6.ude pcmcia-storage-modules-4.15.0-55-generic-di_4.15.0-55.60_amd64.udeb


###############################################################################
# Stage 1
###############################################################################
FROM ubuntu:bionic

COPY --from=0 /var/breqwatr /var/breqwatr/

RUN apt-get update \
 && mkdir -p \
     /var/breqwatr/pxe/http \
     /var/breqwatr/pxe/tftp \
 && apt-get install -y --no-install-recommends \
     coreutils \
     dnsmasq \
     inetutils-ping \
     iptables \
     nginx \
     openssh-client \
     python \
     python-pip \
 && pip install \
     jinja2 \
     netifaces \
 && cd /var/breqwatr/pxe/tftp \
 && ln -s . /var/breqwatr/pxe/http/ubuntu \
 && ln -s ubuntu-installer/amd64/pxelinux.0 pxelinux.0 \
 && ln -s ubuntu-installer/amd64/pxelinux.cfg pxelinux.cfg \
 && ln -s ubuntu-installer/amd64/boot-screens/ldlinux.c32 ldlinux.c32 \
 && cd /var/breqwatr/pxe/tftp/ubuntu-installer/amd64/pxelinux.cfg/ \
 && ln -s ../boot-screens/syslinux.cfg default \
 && chmod -R 0755 /var/breqwatr/pxe/http \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /etc/nginx/sites-enabled/default

COPY image-files/ /

ENV \
  INTERFACE='' \
  DHCP_RANGE_START='' \
  DHCP_RANGE_END='' \
  DNS_IP='8.8.8.8'

CMD /bin/bash /start.sh
