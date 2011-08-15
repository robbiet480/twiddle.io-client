export GO_EASY_ON_ME=1
include theos/makefiles/common.mk

TOOL_NAME = twiddlio
twiddlio_FILES = main.m $(wildcard *.m) 
twiddlio_FRAMEWORKS = CFNetwork SystemConfiguration MobileCoreServices CoreGraphics Foundation UIKit CoreTelephony
twiddlio_PRIVATE_FRAMEWORKS = CoreTelephony

ADDITIONAL_LDFLAGS = -licucore -lz -lxml2

include $(THEOS_MAKE_PATH)/tool.mk
