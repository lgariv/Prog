INSTALL_TARGET_PROCESSES = SpringBoard
include $(THEOS)/makefiles/common.mk

# export GO_EASY_ON_ME = 1

export FINALPACKAGE = 1
DEBUG = 0
export ARCHS = arm64 arm64e
export TARGET = iphone:clang:13.5

TWEAK_NAME = Prog

Prog_FILES = Tweak.xm welcome.xm
Prog_FRAMEWORKS = Foundation UIKit QuartzCore
Prog_PRIVATE_FRAMEWORKS = BulletinBoard FrontBoardServices
Prog_CFLAGS = -O2 -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
