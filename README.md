About
=====

Personal scripts for working with Android at Linaro

Requirements
============

Currently the script assumes that you have repo and other host prerequisites
for android. It has been tested on Ubuntu 12.04 and Ubuntu 10.04

Usage
=====

Once you are good to go run this:

```
$ git clone git://github.com/zyga/android-build-scripts.git
$ cd android-build-scripts
$ make
```

To flash that to a bootable SD card run:

```
$ make flash
```