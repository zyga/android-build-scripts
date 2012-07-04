# :vim: set sw=4 ts=4 noexpandtab
# Simple recursive build system for Android / Linaro
# Copyright (C) 2012 Zygmunt Krynicki
#
# NOTE: since this is a recursive build system it suffers the pitfalls of that design.
# The trade-off is precision over convenience and speed.

# Include the panda specific settings
# TODO: Add support for other builds
include panda.mk

# ---
# Common variables
# ---
#
# Output directory where the android build system spits out
# tarballs we care about
OUT_DIR	= android/out/target/product/$(TARGET_PRODUCT)/
# Force all locale to C
export LANG=C
# Toolchain location
TARGET_TOOLS_PREFIX := $(shell pwd)/android-toolchain-eabi/bin/arm-linux-androideabi-
pass-to-make += TARGET_TOOLS_PREFIX

# ---
# Rule to remove products of rules that fail to execute successfully
# --- 
.DELETE_ON_ERROR:

# ---
# Special variable to make 'all' the default goal
# ---
.DEFAULT_GOAL := all

# ---
# Rule to create additional directories 
# ---
toolchain downloads android : % : 
	mkdir -p $@

# ---
# Rule to initialize repo for our build
# ---
android/.repo: | android
	cd android && repo init -u $(MANIFEST_REPO) -b $(MANIFEST_BRANCH) -m $(MANIFEST_FILENAME)

# ---
# Rule to fetch the toolchain archive
# ---
toolchain_archive := downloads/$(shell basename $(TOOLCHAIN_URL))
$(toolchain_archive): | downloads 
	wget --no-check-certificate $(TOOLCHAIN_URL) -O $@

# ---
# Rule to unpack the toolchain archive
# ---
android-toolchain-eabi: | $(toolchain_archive)
	tar -jxf $(toolchain_archive)

# ---
# Rule to build everything needed to run flash a moment later
# ---
.PHONY: all
all: $(addprefix $(OUT_DIR),system.tar.bz2 boot.tar.bz2 userdata.tar.bz2)

# ---
# Rule to build the three tarballs we need to make the SD card
# ---
$(addprefix $(OUT_DIR),system.tar.bz2 boot.tar.bz2 userdata.tar.bz2): %.tar.bz2 : | android/.repo android/Makefile android-toolchain-eabi
	$(MAKE) -C android  \
		$(foreach var,$(pass-to-make),$(var)=$(value $(var))) \
		$(notdir $*)tarball showcommands

# ---
# Rule to synchronize repository
# ---
.PHONY: sync
android/Makefile sync: | android/.repo
	cd android && repo sync

# ---
# Rule to create a bootable card
# ---
get-mmc-from-env=$(SDCARD_TO_FLASH)
get-mmc-from-system-label=$(shell test -h /dev/disk/by-label/system && echo /dev/$$(echo $$(basename $$(readlink /dev/disk/by-label/system)) | cut -b 1-3))
get-mmc-error=$(error Unable to guess SD card location, either set SDCARD_TO_FLASH or insert a pre-formatted card with a partition labelled 'system')
.PHONY: flash
flash: $(addprefix $(OUT_DIR),system.tar.bz2 boot.tar.bz2 userdata.tar.bz2)
	linaro-android-media-create \
		--dev panda \
		--mmc $(or $(get-mmc-from-env),$(get-mmc-from-system-label),$(get-mmc-error)) \
		--system $(OUT_DIR)/system.tar.bz2 \
		--boot $(OUT_DIR)/boot.tar.bz2 \
		--userdata $(OUT_DIR)/userdata.tar.bz2 \

# ---
# Rule to clean the build tree
# ---
.PHONY: clean
clean: | android android/.repo android-toolchain-eabi
	$(MAKE) -C android \
		$(foreach var,$(pass-to-make),$(var)=$(value $(var))) \
		$@
	cd android && repo forall -c git clean -f -x -d
