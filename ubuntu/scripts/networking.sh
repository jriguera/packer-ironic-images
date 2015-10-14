#!/bin/bash -eux

echo "* Installing vlan packages"
apt-get install -y vlan

echo "* Adding vlan module to modules"
grep -q 8021q /etc/modules || echo 8021q >> /etc/modules

echo "* Adding bonding to modules"
grep -q bonding /etc/modules || echo bonding >> /etc/modules

echo "* Installing bridge-utils for linux bridges"
apt-get install -y bridge-utils

echo "* Installing ifenslave for bonding"
apt-get install -y ifenslave

