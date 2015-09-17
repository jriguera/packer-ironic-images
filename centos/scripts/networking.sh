#!/bin/bash -eux

echo "* Adding bond0 module alias"
grep -q bond0 /etc/modprobe.d/bonding.conf || echo "alias bond0 bonding" > /etc/modprobe.d/bonding.conf

echo "* Installing vconfig"
yum install -y vconfig

echo "* Installing bridge-utils"
yum install -y bridge-utils

