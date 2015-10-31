include theos/makefiles/common.mk

export ARCHS = armv7 arm64
ADDITIONAL_OBJCFLAGS = -fobjc-arc

BUNDLE_NAME = CirDockSettings
CirDockSettings_FILES = PSCirDockSwitch.mm PSStepperCell.mm ./Tutorial/CirDockHoldTutViewController.m ./Tutorial/CirDockTapTutViewController.m ./Tutorial/Panel.m ./Tutorial/PurchaseViewController.m ./Tutorial/TutViewController.m UIAlertView+Blocks.m NSString+Emojize.m UIImage+CoreGraphics.m HRBrightnessCursor.m HRBrightnessSlider.m HRColorCursor.m HRColorInfoView.m HRColorMapView.m HRColorPickerView.m HRHSVColorUtil.m PSColorPicker.mm PSIECell.mm CirDockFavoritesController.mm CirDockBadgeController.mm CirDockHoldController.mm CirDockApplicationsController.mm PSColoredCell.mm iCarousel.m PSCarouselCell.mm CirDockSettings.mm
CirDockSettings_INSTALL_PATH = /Library/PreferenceBundles
CirDockSettings_FRAMEWORKS = UIKit QuartzCore CoreGraphics Accounts Social MessageUI
CirDockSettings_PRIVATE_FRAMEWORKS = Preferences
CirDockSettings_LIBRARIES = applist

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/CirDockSettings.plist$(ECHO_END)
