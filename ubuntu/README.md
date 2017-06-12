# Ubuntu packer templates

## Howto

To create an qcow2 image for ironic, based on the official ubuntu 14.04.3 iso:
```bash
packer build -var 'headless=false' ubuntu-14.04.3-amd64.json
```
Packer will cache the ISO image, so the second time it will be faster.
_'headless=false'_ will show all the install process via VNC.


To create image without VNC (default mode)
```bash
# To perform an Ubuntu netboot install (it takes always latest version)
packer build ubuntu-14.04.latest-amd64.json
```
Probably this way is slow because it first downloads a minimal ISO install CD and
then install all the packages from the internet. The result is a system completely
updated.


## Software pre-installed

Look in scripts/packages.sh


## Proxy

If proxy is needed on your network configuration edit the ubuntu preseed files and add:
```
d-i mirror/http/proxy http://YOURPROXY:YOURPORT
```

Also  you need to add the proxy to the packer template in the `variables` section or
pass it with the `-var` packer flag. Anyway you have to edit the pressed file,
because the Debian/Ubuntu installer does not offer a way to ignore the HTTP packer
internal webserver to request the pressed file, everything will go via the global
proxy and the installer will fail to get such file.


