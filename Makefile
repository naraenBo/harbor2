include $(THEOS)/makefiles/common.mk

export ARCHS = arm64

TWEAK_NAME = Harbor2
Harbor2_FILES = Tweak.xm HBRPrefs.m

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += harbor2prefs
include $(THEOS_MAKE_PATH)/aggregate.mk
