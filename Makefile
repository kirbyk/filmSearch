export ARCHS = armv7 arm64

include theos/makefiles/common.mk

BUNDLE_NAME = imdbSearch
imdbSearch_FILES = imdbSearch.m
imdbSearch_INSTALL_PATH = /Library/SearchLoader/SearchBundles
imdbSearch_BUNDLE_EXTENSION = searchBundle
imdbSearch_LDFLAGS = -lspotlight
imdbSearch_PRIVATE_FRAMEWORKS = Search

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications
	cp -r InfoBundle/ $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications/imdbSearch.bundle

	mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Preferences
	cp imdbSearch.plist $(THEOS_STAGING_DIR)/Library/SearchLoader/Preferences/imdbSearch.plist

internal-after-install::
	install.exec "killall -9 backboardd searchd AppIndexer &>/dev/null"
