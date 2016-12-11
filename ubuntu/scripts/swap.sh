#!/bin/bash -eux

# swap is handled by cloud-init
echo "* Remove swap fstab"
sed -i '/^\/dev\/mapper\/system-swap/d' /etc/fstab
