export ARCHS = armv7 arm64

include theos/makefiles/common.mk

BUNDLE_NAME = filmSearch
filmSearch_FILES = filmSearch.m
filmSearch_INSTALL_PATH = /Library/SearchLoader/SearchBundles
filmSearch_BUNDLE_EXTENSION = searchBundle
filmSearch_LDFLAGS = -lspotlight
filmSearch_PRIVATE_FRAMEWORKS = Search

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications
	cp -r InfoBundle/ $(THEOS_STAGING_DIR)/Library/SearchLoader/Applications/filmSearch.bundle

	mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/Preferences
	cp filmSearch.plist $(THEOS_STAGING_DIR)/Library/SearchLoader/Preferences/filmSearch.plist

internal-after-install::
	install.exec "killall -9 backboardd searchd AppIndexer &>/dev/null"
