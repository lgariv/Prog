INSTALL_TARGET_PROCESSES = SpringBoard
include $(THEOS)/makefiles/common.mk

export FINALPACKAGE = 1
DEBUG = 0
export ARCHS = arm64 #arm64e

TWEAK_NAME = DownloadBar14

DownloadBar14_FILES = Tweak.xm
# DownloadBar14_LIBRARIES = libbulletin
DownloadBar14_CFLAGS = -O2 -fobjc-arc
DownloadBar14_FRAMEWORKS = Foundation UIKit UserNotifications QuartzCore
DownloadBar14_PRIVATE_FRAMEWORKS = BulletinBoard

include $(THEOS_MAKE_PATH)/tweak.mk
