#!/bin/bash -eux

UPGRADE=${UBUNTU_UPGRADE:-no}

echo "* Updating from repositories"
# apt-get update does not actually perform updates, it just downloads and indexes the list of packages
apt-get -y update

if [ -z "${UPGRADE##*true*}" ] || [ -z "${UPGRADE##*1*}" ] || [ -z "${UPGRADE##*yes*}" ]; then
    echo "* Performing upgrade (all packages and kernel)"
    apt-get -y dist-upgrade --force-yes
    reboot
    sleep 60
fi

