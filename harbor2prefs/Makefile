include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = harbor2prefs
harbor2prefs_FILES = HBRRootListController.m ../HBRPrefs.m
harbor2prefs_INSTALL_PATH = /Library/PreferenceBundles
harbor2prefs_FRAMEWORKS = UIKit
harbor2prefs_PRIVATE_FRAMEWORKS = Preferences
harbor2prefs_LDFLAGS = -F$(THEOS)/sdks/iPhoneOS.sdk/System/Library/PrivateFrameworks

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/harbor2prefs.plist$(ECHO_END)
