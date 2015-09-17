#!/bin/bash -eux

UPGRADE=${CENTOS_UPGRADE:-no}

echo "* Updating from repositories"
yum -y update

if [ -z "${UPGRADE##*true*}" ] || [ -z "${UPGRADE##*1*}" ] || [ -z "${UPGRADE##*yes*}" ]; then
    echo "* Performing upgrade (all packages and kernel)"
    yum -y distro-sync
    yum -y upgrade
    reboot
    sleep 60
fi

