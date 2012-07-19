# :vim: set sw=4 ts=4 noexpandtab
# Simple recursive build system for Android / Linaro
# Copyright (C) 2012 Zygmunt Krynicki
#
# NOTE: since this is a recursive build system it suffers the pitfalls of that design.
# The trade-off is precision over convenience and speed.

# Ensure we have a configuration variable
CONFIGURATION ?= $(error You need to specify CONFIGURATION with the name of the config you want to build)

# Load configuration specific data
include $(CONFIGURATION).mk

# ---
# Common variables
# ---
#
# Output directory where the android build system spits out
# tarballs we care about
OUT_DIR	= $(CONFIGURATION)/android/out/target/product/$(TARGET_PRODUCT)/
# Force all locale to C
export LANG=C
# Toolchain location
TARGET_TOOLS_PREFIX := $(shell pwd)/$(CONFIGURATION)/toolchain/android-toolchain-eabi/bin/arm-linux-androideabi-
# List of variables that have to be passed to make
pass-to-make += TARGET_TOOLS_PREFIX TARGET_PRODUCT TARGET_SIMULATOR TARGET_BUILD_VARIANT

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
$(CONFIGURATION) $(CONFIGURATION)/build-logs $(CONFIGURATION)/toolchain downloads $(CONFIGURATION)/android : % :
	mkdir -p $@

# ---
# Rule to initialize repo for our build
# ---
$(CONFIGURATION)/android/.repo: | $(CONFIGURATION)/android
	cd $(CONFIGURATION)/android && repo init -u $(MANIFEST_REPO) -b $(MANIFEST_BRANCH) -m $(MANIFEST_FILENAME)

# ---
# Rule to fetch the toolchain archive
# ---
toolchain_archive := downloads/$(shell basename $(TOOLCHAIN_URL))
$(toolchain_archive): | downloads 
	wget --no-check-certificate $(TOOLCHAIN_URL) -O $@

ifdef SOURCE_OVERLAY
# ---
# Rule that instructs the user to download the overlay archive
# ---
overlay_base_url=http://snapshots.linaro.org/android/binaries/
overlay_url:=$(shell echo $(overlay_base_url)$(SOURCE_OVERLAY))
overlay_archive:=$(shell echo downloads/$(SOURCE_OVERLAY))
$(overlay_archive): | downloads
	@echo "Sadly, you need to download overlays yourself so that you can see the EULA"
	@echo "So please open $(overlay_url)"
	@echo "And save it as $@"
	false

# ---
# Rule that requests the overlay to be applied to the source
# ---
.PHONY: apply-overlay
apply-overlay: $(CONFIGURATION)/overlay-list.txt

# ---
# Rule that applies the overlay tarball to the source tree
# ---
$(CONFIGURATION)/overlay-list.txt: $(overlay_archive) | $(CONFIGURATION) $(CONFIGURATION)/android
	tar -jxvf $^ -C $(CONFIGURATION)/android > $@

# ---
# Rule that removes the overlay tarball's files from the source tree
# ---
.PHONY: unapply-overlay
unapply-overlay: | $(CONFIGURATION)/overlay-list.txt
	for item in `cat $(CONFIGURATION)/overlay-list.txt`; do \
		test -f "$(CONFIGURATION)/android/$$item" && rm -v "$(CONFIGURATION)/android/$$item" || :; \
	done
	rm -f $(CONFIGURATION)/overlay-list.txt

clean: unapply-overlay
all: $(CONFIGURATION)/overlay-list.txt
endif

# ---
# Rule to unpack the toolchain archive
# ---
$(CONFIGURATION)/toolchain/android-toolchain-eabi: | $(toolchain_archive) $(CONFIGURATION)/toolchain
	tar -jxf $(toolchain_archive) -C $(CONFIGURATION)/toolchain/

# ---
# Rule to build everything needed to run flash a moment later
# ---
last-build-num=$(or $(strip $(shell cat $(CONFIGURATION)/.build-id 2>/dev/null)),0)
pin-build-number=$(eval pinned-build-num:=$(shell expr $(last-build-num) + 1))
current-build-num=$(or $(pinned-build-num),$(pin-build-number),$(pinned-build-num))
.PHONY: all
all: | $(CONFIGURATION)/android/.repo $(CONFIGURATION)/android/Makefile $(CONFIGURATION)/toolchain/android-toolchain-eabi $(CONFIGURATION)/build-logs
	echo $(current-build-num) > $(CONFIGURATION)/.build-id
	$(MAKE) -C $(CONFIGURATION)/android  \
		$(foreach var,$(pass-to-make),$(if $(value $(var)),$(var)=$(value $(var)),)) \
		$(addsuffix tarball, boot system userdata) showcommands \
		>$(CONFIGURATION)/build-logs/build-$(current-build-num).log 2>&1

# ---
# Rule to build the three tarballs we need to make the SD card
# ---
$(addprefix $(OUT_DIR),system.tar.bz2 boot.tar.bz2 userdata.tar.bz2):
	@echo "NOTE: To build each of the tarballs simply run 'make all'"
	@echo "It seems that android build system is not stable"
	@echo "(subsequent builds keep building stuff)"
	@echo "so I made sure that 'make flash' won't build stuff for you"
	@false

# ---
# Rule to synchronize repository
# ---
.PHONY: sync
$(CONFIGURATION)/android/Makefile sync: | $(CONFIGURATION)/android/.repo
	cd $(CONFIGURATION)/android && repo sync

# ---
# Rule to create a bootable card
# ---
get-mmc-from-env=$(SDCARD_TO_FLASH)
get-mmc-from-system-label=$(shell test -h /dev/disk/by-label/system && echo /dev/$$(echo $$(basename $$(readlink /dev/disk/by-label/system)) | cut -b 1-3))
get-mmc-error=$(error Unable to guess SD card location, either set SDCARD_TO_FLASH or insert a pre-formatted card with a partition labelled 'system')
.PHONY: flash
flash: $(addprefix $(OUT_DIR),system.tar.bz2 boot.tar.bz2 userdata.tar.bz2)
	linaro-android-media-create \
		--dev $(lmc-dev) \
		--mmc $(or $(get-mmc-from-env),$(get-mmc-from-system-label),$(get-mmc-error)) \
		--system $(OUT_DIR)system.tar.bz2 \
		--boot $(OUT_DIR)boot.tar.bz2 \
		--userdata $(OUT_DIR)userdata.tar.bz2

# ---
# Rule to create a SD card image.
#
# The primary use case is for snowball_emmc, so that we can use riff
# --
.PHONY: image
image: $(CONFIGURATION).img

$(CONFIGURATION).img: $(addprefix $(OUT_DIR),system.tar.bz2 boot.tar.bz2 userdata.tar.bz2)
	linaro-android-media-create \
		--dev $(lmc-dev) \
		--image-file $(CONFIGURATION).img \
		--image-size 1500M \
		--system $(OUT_DIR)system.tar.bz2 \
		--boot $(OUT_DIR)boot.tar.bz2 \
		--userdata $(OUT_DIR)userdata.tar.bz2


# ---
# Inject special dependencies for image and flash when we're dealing with snowball_emmc
# ---
ifeq ($(lmc-dev),snowball_emmc)
image: startupfiles
flash: flash-fail-emmc

# AFAIK flash just does not work for snowball_emmc
.PHONY: flash-fail-emmc
flash-fail-emmc:
	@echo "The flash target does not work with snowball_emmc, use 'make image' and 'make riff'"
	false

# Another binary blob the user has to EULA-click-through, meh
startupfiles:
	@echo "You need to download Snoball eMMC startup files yourself"
	@echo "The link to get them is:"
	@echo "http://www.igloocommunity.org/download/linaro/startupfiles/latest/"
	@echo "Then unpack them here (there should be a directory called $@)"
	false

# Phony target to copy the snowball image to a board
.PHONY: riff
riff: $(CONFIGURATION).img
	@echo "Unplug all cables from your board (including power) and press [enter]"
	@read DUMMY
	@echo "Plug the USB cable to the OTG port (between power and audio connectors)"
	@echo "Do that and press [enter]"
	@read DUMMY
	sudo riff -f $@
	@echo "Plug back the power cable and turn on the board"
endif

# ---
# Rule to clean the build tree
# ---
.PHONY: clean
clean: | $(CONFIGURATION)/android $(CONFIGURATION)/android/.repo $(CONFIGURATION)/toolchain/android-toolchain-eabi
	$(MAKE) -C $(CONFIGURATION)/android \
		$(foreach var,$(pass-to-make),$(if $(value $(var)),$(var)=$(value $(var)),)) \
		$@
	cd $(CONFIGURATION)/android && repo forall -c git clean -f -x -d
