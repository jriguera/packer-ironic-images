#!/bin/bash -eux

echo "* Disk usage before minimization"
df -h

echo "* Clean up orphaned packages with deborphan"
apt-get -y install deborphan
while [ -n "$(deborphan --guess-all --libdevel)" ]; do
    deborphan --guess-all --libdevel | xargs apt-get -y purge
done
apt-get -y purge deborphan dialog

echo "* Removing man pages"
rm -rf /usr/share/man/*
echo "* Removing APT files"
find /var/lib/apt -type f | xargs rm -f
echo "* Removing any docs"
rm -rf /usr/share/doc/*
echo "* Removing caches"
find /var/cache -type f -exec rm -rf {} \;

echo "* Disk usage after cleanup"
df -h
