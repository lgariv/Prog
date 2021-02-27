INSTALL_TARGET_PROCESSES = SpringBoard
include $(THEOS)/makefiles/common.mk

#export GO_EASY_ON_ME = 1

export FINALPACKAGE = 1
DEBUG = 0
export ARCHS = arm64 arm64e
export TARGET = iphone:clang:13.5
export TARGET = iphone:clang:14.0:13.5 # gitignore

TWEAK_NAME = DownloadBar14

DownloadBar14_FILES = Tweak.xm
DownloadBar14_FRAMEWORKS = Foundation UIKit QuartzCore
DownloadBar14_PRIVATE_FRAMEWORKS = BulletinBoard FrontBoardServices
DownloadBar14_CFLAGS = -O2 -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
