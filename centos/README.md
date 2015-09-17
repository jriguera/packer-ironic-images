# Centos packer templates

## Howto

To create an qcow2 image for ironic, based on the official Centos 6.7 iso:
```bash
packer build -var 'headless=false' centos-6.7-amd64.json
```
Packer will cache the ISO image, so the second time it will be faster.
_'headless=false'_ will show all the install process via VNC.


To create image without VNC (default mode)
```bash
packer build centos-6.7-amd64.json
```

## Software pre-installed

Look in scripts/packages.sh
