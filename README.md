Nodejs5 package for OpenWrt
============================

## Brief introduction

The project is nodejs compiled specially for OpenWrt, it also includes npm (if desired)

Ccurrent version: v5.6.0 which is the newest build at the time.

## Compile

From the OpenWrt SDK to compile
```
# In ar71xx platform as an example
tar xjf OpenWrt-SDK-ar71xx-for-linux-x86_64-gcc-4.8-linaro_uClibc-0.9.33.2.tar.bz2
cd OpenWrt-SDK-ar71xx-*
# Create package directories
mkdir package/utils
# Clone Makefile
git clone https://github.com/qianguozheng/nodejs-openwrt4 package/utils/nodejs5
# Select the package to be compiled Utilities -> nodejs
# also chose any advanced options for compilation
make menuconfig
# Compile Package
make package/nodejs5/{clean,compile} V=99
```

***Notice***
The node binary is about 12M Bytes after strip by mips toolchain, So,
if your FLASH_SIZE is not bigger enough, less than 16MB, the firmware
may not be generate(like openwrt-ramips-MODEL-squash-sysupgrade.bin),
you can cp the node binary to firmware /tmp folder to test.

## Contributions

Thanks to @qianguozheng for initial idea.
Thanks to @hongkongkiwi for version 4
