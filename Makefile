export ARCHS = armv7 arm64

include theos/makefiles/common.mk

BUNDLE_NAME = SpotiSearchTracks
SpotiSearchTracks_FILES = Tracks.m
SpotiSearchTracks_INSTALL_PATH = /Library/SearchLoader/SearchBundles
SpotiSearchTracks_BUNDLE_EXTENSION = searchBundle
SpotiSearchTracks_LDFLAGS = -lspotlight
SpotiSearchTracks_PRIVATE_FRAMEWORKS = Search

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications
	cp -r InfoBundle/ $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications/SpotiSearchTracks.bundle

	mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Preferences
	cp Tracks.plist $(THEOS_STAGING_DIR)/Library/SearchLoader/Preferences/SpotiSearchTracks.plist

internal-after-install::
	install.exec "killall -9 backboardd searchd AppIndexer &>/dev/null"
