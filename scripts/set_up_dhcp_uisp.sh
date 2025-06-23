#!/bin/bash

configure
set service dhcp-server shared-network-name LAN subnet 192.168.1.0/24 start 192.168.1.100 stop 192.168.1.200
set service dhcp-server shared-network-name LAN subnet 192.168.1.0/24 default-router 192.168.1.1
set service dhcp-server shared-network-name LAN subnet 192.168.1.0/24 dns-server 8.8.8.8

# Add PXE options
set service dhcp-server shared-network-name LAN subnet 10.0.3.0/24 subnet-parameters 'option-66 ascii 10.0.3.11'
set service dhcp-server shared-network-name LAN subnet 10.0.3.0/24 subnet-parameters 'option-67 ascii pxelinux.0'

commit
save
exit

# The &quot; value is used to replace the quotation marks (") to allow a part of the string to be quoted inside the single quote (') section