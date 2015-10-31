#import <Preferences/Preferences.h>
#import "HRColorPickerView.h"
#import "HRBrightnessSlider.h"

@interface PSColorPicker: PSListController {
	NSString *defaultsName, *keyName;
}
@property (nonatomic, retain) NSString *defaultsName, *keyName;
@property (nonatomic, retain) HRColorPickerView *colorPicker;
@property (nonatomic, retain) UIColor *defaultColor;

- (void)colorDidChanged:(HRColorPickerView *)pickerView;
@end