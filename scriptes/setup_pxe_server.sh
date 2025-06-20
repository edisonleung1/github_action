#!/bin/bash
set -e

echo "Installing PXE dependencies..."
yum install -y httpd tftp-server syslinux

echo "Starting services..."
systemctl enable --now tftp.socket
systemctl enable --now httpd

echo "Setting up TFTP boot files..."
mkdir -p /var/lib/tftpboot/pxelinux.cfg
cp /usr/share/syslinux/pxelinux.0 /var/lib/tftpboot/

echo "Downloading kernel/initrd..."
curl -o /var/www/html/vmlinuz http://mirror.centos.org/centos/7/os/x86_64/images/pxeboot/vmlinuz
curl -o /var/www/html/initrd.img http://mirror.centos.org/centos/7/os/x86_64/images/pxeboot/initrd.img

echo "Creating PXE menu config..."
cat <<EOF > /var/lib/tftpboot/pxelinux.cfg/default
default menu.c32
prompt 1
timeout 60
ONTIMEOUT auto
label auto
  menu label Install CentOS 7
  kernel /vmlinuz
  append initrd=/initrd.img inst.ks=http://192.168.1.10/kickstart.cfg
EOF

echo "Adjusting firewall..."
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=tftp
firewall-cmd --reload

echo "PXE setup complete."
