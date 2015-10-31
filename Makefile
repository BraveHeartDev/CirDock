include theos/makefiles/common.mk

export ARCHS = armv7 arm64

SUBPROJECTS += cirdocksettings
include $(THEOS_MAKE_PATH)/aggregate.mk

TWEAK_NAME = Cirdock
Cirdock_FILES = NSArray+LongestCommonSubsequence.m iCarousel.m UIAlertView+Blocks.m Tweak.xm
Cirdock_FRAMEWORKS = UIKit QuartzCore CoreGraphics
Cirdock_PRIVATE_FRAMEWORKS = AppSupport
Cirdock_CFLAGS = -fobjc-arc
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
