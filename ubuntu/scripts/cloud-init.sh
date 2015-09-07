#!/bin/bash -eux

DATASOURCE_LIST="ConfigDrive, Openstack, None"
# Comma list of choices: 
#    NoCloud: Reads info from /var/lib/cloud/seed only, 
#    ConfigDrive: Reads data from Openstack Config Drive, 
#    OpenNebula: read from OpenNebula context disk, 
#    Azure: read from MS Azure cdrom. Requires walinux-agent, 
#    AltCloud: config disks for RHEVm and vSphere, 
#    OVF: Reads data from OVF Transports, 
#    MAAS: Reads data from Ubuntu MAAS, 
#    GCE: google compute metadata service, 
#    OpenStack: native openstack metadata service, 
#    CloudSigma: metadata over serial for cloudsigma.com, 
#    Ec2: reads data from EC2 Metadata service, 
#    CloudStack: Read from CloudStack metadata service, 
#    None: Failsafe datasource

### Install debconf-utils for automatic configuration
echo "* Setting up default debconf config for cloud-init"
apt-get install -y debconf-utils
### Create configuration
echo "cloud-init      cloud-init/datasources  multiselect     ${DATASOURCE_LIST}" > /tmp/cloud-init.preseed
cat /tmp/cloud-init.preseed | debconf-set-selections

### Install packages
echo "* Installing cloud-init"
apt-get install -y cloud-init cloud-initramfs-growroot

### Setup main configuration
echo "* Installing cloud-init configuration"
cat <<EOF > /etc/cloud/cloud.cfg
# The top level settings are used as module
# and system configuration.

# A set of users which may be applied and/or used by various modules
# when a 'default' entry is found it will reference the 'default_user'
# from the distro configuration specified below
users:
 - default

# If this is set, 'root' will not be able to ssh in and they 
# will get a message to login instead as the above $user (ubuntu)
disable_root: true

# This will cause the set+update hostname module to not operate (if true)
preserve_hostname: false

# Example datasource config
# datasource: 
#    Ec2: 
#      metadata_urls: [ 'blah.com' ]
#      timeout: 5 # (defaults to 50 seconds)
#      max_wait: 10 # (defaults to 120 seconds)

# The modules that run in the 'init' stage
cloud_init_modules:
 - migrator
 - seed_random
 - bootcmd
 - write-files
 - growpart
 - resizefs
 - set_hostname
 - update_hostname
 - update_etc_hosts
 - ca-certs
 - rsyslog
 - users-groups
 - ssh

# The modules that run in the 'config' stage
cloud_config_modules:
# Emit the cloud config ready event
# this can be used by upstart jobs for 'start on cloud-config'.
 - emit_upstart
 - disk_setup
 - mounts
 - ssh-import-id
 - locale
 - set-passwords
 - grub-dpkg
 - apt-pipelining
 - apt-configure
 - package-update-upgrade-install
 - landscape
 - timezone
 - puppet
 - chef
 - salt-minion
 - mcollective
 - runcmd
 - byobu

# The modules that run in the 'final' stage
cloud_final_modules:
 - rightscale_userdata
 - scripts-vendor
 - scripts-per-once
 - scripts-per-boot
 - scripts-per-instance
 - scripts-user
 - ssh-authkey-fingerprints
 - keys-to-console
 - phone-home
 - final-message
 - power-state-change

# System and/or distro specific settings
# (not accessible to handlers/transforms)
system_info:
   # This will affect which distro class gets used
   distro: ubuntu
   # Default user name + that default users groups (if added/used)
   default_user:
     name: ubuntu
     lock_passwd: False
     plain_text_passwd: 'ubuntu'
     gecos: Ubuntu
     groups: [adm, audio, cdrom, dialout, dip, floppy, netdev, plugdev, sudo, video]
     sudo: ["ALL=(ALL) NOPASSWD:ALL"]
     shell: /bin/bash
   # Other config here will be given to the distro class and/or path classes
   paths:
      cloud_dir: /var/lib/cloud/
      templates_dir: /etc/cloud/templates/
      upstart_dir: /etc/init/
   package_mirrors:
     - arches: [i386, amd64]
       failsafe:
         primary: http://archive.ubuntu.com/ubuntu
         security: http://security.ubuntu.com/ubuntu
       search:
         primary:
           - http://%(ec2_region)s.ec2.archive.ubuntu.com/ubuntu/
           - http://%(availability_zone)s.clouds.archive.ubuntu.com/ubuntu/
         security: []
   ssh_svcname: ssh

EOF

### Setup LVM PV grow
echo "* Installing grow PV configuration"
cat <<EOF > /etc/cloud/cloud.cfg.d/10_growpv.cfg
# growpart entry is a dict, if it is not present at all
# in config, then the default is used ({'mode': 'auto', 'devices': ['/']})
#
#  mode:
#    values:
#     * auto: use any option possible (any available)
#             if none are available, do not warn, but debug.
#     * growpart: use growpart to grow partitions
#             if growpart is not available, this is an error.
#     * off, false
#
# devices:
#   a list of things to resize.
#   items can be filesystem paths or devices (in /dev)
#   examples:
#     devices: [/, /dev/vdb1]
#
# ignore_growroot_disabled:
#   a boolean, default is false.
#   if the file /etc/growroot-disabled exists, then cloud-init will not grow
#   the root partition.  This is to allow a single file to disable both
#   cloud-initramfs-growroot and cloud-init's growroot support.
#
#   true indicates that /etc/growroot-disabled should be ignored
#
growpart:
  mode: auto
  devices: ['/dev/sda2', '/dev/vda2']
  ignore_growroot_disabled: false

# boot commands
# default: none
# this is very similar to runcmd, but commands run very early
# in the boot process, only slightly after a 'boothook' would run.
# bootcmd should really only be used for things that could not be
# done later in the boot process.  bootcmd is very much like
# boothook, but possibly with more friendly.
#  * bootcmd will run on every boot
#  * the INSTANCE_ID variable will be set to the current instance id.
#  * you can use 'cloud-init-boot-per' command to help only run once
bootcmd:
 - [ cloud-init-per, once, pvresize, /dev/sda2, /dev/vda2 ]

EOF

### Clean
echo "* Cleaning"
apt-get remove -y --purge debconf-utils
rm -f /tmp/cloud-init.preseed

