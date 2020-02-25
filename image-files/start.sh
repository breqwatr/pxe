#!/bin/bash
# set -e

# Apply environmnet variables in config files
echo "INFO: Applying environment variables"
/env_config.py

# configure iptables NAT (PAT) so PXE server can act as gateway
# If the deployment server has no defgw, this file is not created
if [[ -f /etc/iptables ]]; then
  echo "INFO: Setting iptables NAT rule"
  iptables-restore < /etc/iptables
else
  echo "WARNING: No default route on host - not setting NAT rule in iptables"
fi

# Start NGINX to serve the apt files that were copied from the ISO
service nginx start

# NOTE(Kyle):
# Not sure why, but something is messing with the perissions at startup for
# the http files
chmod -R 0755 /var/breqwatr/pxe/http

# Start DNSMASK (the actual Dockerfile CMD)
# /dnsmasq.sh is created by env_config.py
bash /dnsmasq.sh
