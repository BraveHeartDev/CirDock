#import <Preferences/Preferences.h>

@interface PSIECell : PSTableCell
@property (nonatomic, retain) UIButton *importBtn, *exportBtn;

- (void)Import;
- (void)Export;
- (NSArray*)settingsFilesDifferencesWithDict:(NSDictionary*)dict1 andDict:(NSDictionary*)dict2;
@end