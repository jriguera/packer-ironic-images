#!/bin/bash -eux

echo "* Disk usage before minimization"
df -h

echo "* Removing man pages"
rm -rf /usr/share/man/*

echo "* Cleaning yum"
yum clean all

echo "* Removing any docs"
rm -rf /usr/share/doc/*

echo "* Removing caches"
find /var/cache -type f -exec rm -rf {} \;

echo "* Recreating RPM DB"
rm -f /var/lib/rpm/__db*
rpm –rebuilddb

echo "* Disk usage after cleanup"
df -h
