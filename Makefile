include $(THEOS)/makefiles/common.mk

ARCHS = arm64

TWEAK_NAME = Harbor2
Harbor2_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
