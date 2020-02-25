# BW-PXE

A service controlled by the
[Breqwatr deployment tool](https://github.com/breqwatr/breqwatr-deployment-tool)


## How to start bw-pxe

```
bwdt pxe start \
  --interface <listen interface name> \
  --dhcp-start <ip address> \
  --dhcp-end <ip address>
```


# How BW-PXE Works

The Dockerfile downloads the Ubuntu 18 iso and the netboot packages, then
extracts the required files from there to enable PXE. It sets up a TFTP service
for PXE over DHCP, and it sets up NGINX to serve the apt file.

The image's CMD runs /start.sh, which runs `/env_config.py` to fill in the
config files using the containers environment variables. Then NGINX is launched
as a systemd service. Finally, DNSMasq is launched as the watched process of
the container, with its output going to stdout so you can watch it with
`docker logs`
