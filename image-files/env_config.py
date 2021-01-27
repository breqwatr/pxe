#!/usr/bin/env python3
"""Apply environment variables to arcus-api's config files"""

import os
# netifaces breaks pylint. Remove this to check your work:
# pylint: disable=all
import netifaces
from jinja2 import Template


def apply_template(jinja2_file, output_file, replacements):
    """Replace the replacements values in jinja2_file, write to output_file"""
    with open(jinja2_file, 'r') as j2_file:
        j2_text = j2_file.read()
    template = Template(j2_text)
    replaced_text = template.render(**replacements)
    with open(output_file, 'w+') as write_file:
        write_file.write(replaced_text)


# Network info, used in >1 template
interface = os.environ['INTERFACE']
iface_ip = netifaces.ifaddresses(interface)[netifaces.AF_INET][0]['addr']
netmask = netifaces.ifaddresses(interface)[netifaces.AF_INET][0]['netmask']

# /etc/iptables
# Only do this if there's a default gateway
gateways = netifaces.gateways()
if 'default' in gateways and netifaces.AF_INET in gateways['default']:
    gw_interface_name = gateways['default'][netifaces.AF_INET][1]
    apply_template(
        jinja2_file='/etc/iptables.j2',
        output_file='/etc/iptables',
        replacements={'gateway_interface': gw_interface_name})


# /dnsmasq.sh
# pylint: disable=superfluous-parens
print('INFO: Using Interface {}, IP: {}'.format(interface, iface_ip))
apply_template(
    jinja2_file='/dnsmasq.sh.j2',
    output_file='/dnsmasq.sh',
    replacements={
        'interface': interface,
        'interface_ip': iface_ip,
        'dhcp_start': os.environ['DHCP_RANGE_START'],
        'dhcp_end': os.environ['DHCP_RANGE_END'],
        'dhcp_subnet': netmask,
        'dns_ip': os.environ['DNS_IP']})


# /var/breqwatr/pxe/tftp/ubuntu-installer/amd64/boot-screens/txt.cfg
txtj2 = '/var/breqwatr/pxe/tftp/ubuntu-installer/amd64/boot-screens/txt.cfg.j2'
txtcfg = '/var/breqwatr/pxe/tftp/ubuntu-installer/amd64/boot-screens/txt.cfg'
apply_template(
    jinja2_file=txtj2,
    output_file=txtcfg,
    replacements={'http_ip': iface_ip})


# /var/breqwatr/pxe/http/preseed/breqwatr.cfg
apply_template(
    jinja2_file='/var/breqwatr/pxe/http/preseed/breqwatr.cfg.j2',
    output_file='/var/breqwatr/pxe/http/preseed/breqwatr.cfg',
    replacements={'http_ip': iface_ip})
