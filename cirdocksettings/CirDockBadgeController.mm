#import <Preferences/Preferences.h>
#define BadgePLISTPATH @"/var/mobile/Library/Preferences/com.braveheart.cirdock.plist"

@interface CirDockBadgeController: PSListController {
}
- (id)readPrefValue:(PSSpecifier*)spec;
- (void)setPrefValue:(id)value specifier:(PSSpecifier*)spec;
@end

@implementation CirDockBadgeController
-(void)setPrefValue:(id)value specifier:(PSSpecifier*)spec
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:BadgePLISTPATH];
    if(!dict)
        dict = [[NSMutableDictionary alloc]init];
    
    NSString *key = [spec propertyForKey:@"key"];
    
    [dict setValue:value forKey:key];
    [dict writeToFile:BadgePLISTPATH atomically:YES];
    
    [spec setProperty:value forKey:@"default"];
    [self reloadSpecifier:spec];
    
    CFNotificationCenterRef centre = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterPostNotification( centre, (__bridge CFStringRef)@"CirDockBadgeChangeNotification", NULL, NULL, YES );
}

-(id)readPrefValue:(PSSpecifier*)spec
{
    NSString *key = [spec propertyForKey:@"key"];
    id defaultValue = [spec propertyForKey:@"default"];
    
    id plistValue;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:BadgePLISTPATH];
    if(dict)
        plistValue = [dict objectForKey:key];
    
    id value;
    if (!plistValue)
        value = defaultValue;
    else
        value = plistValue;
    
    return value;
}

- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[NSMutableArray alloc]init];
        
        PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [specifier setProperty:@"Setting this on will allow applications that aren't enabled in the enabled applications list to be shown if they have a badge on them." forKey:@"footerText"];
        [(NSMutableArray *)_specifiers addObject:specifier];
        
        specifier = [PSSpecifier preferenceSpecifierNamed:@"All Applications Shown" target:self set:@selector(setPrefValue:specifier:) get:@selector(readPrefValue:) detail:nil cell:PSSwitchCell edit:nil];
        [specifier setProperty:@YES forKey:@"enabled"];
        [specifier setProperty:@NO forKey:@"default"];
        [specifier setProperty:@"badgeAllApps" forKey:@"key"];
        [specifier setProperty:NSClassFromString(@"PSCirDockSwitch") forKey:@"cellClass"];
        [(NSMutableArray *)_specifiers addObject:specifier];
    }
    return _specifiers;
}

- (id)navigationTitle
{
    return @"Badges Settings";
}

- (NSString *)title
{
    return @"Badges Settings";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:1 green:80.f/255.f blue:70.f/255.f alpha:1];;
    [[UIApplication sharedApplication] keyWindow].tintColor = [UIColor colorWithRed:1 green:80.f/255.f blue:70.f/255.f alpha:1];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] keyWindow].tintColor = nil;
    self.view.tintColor = nil;
    self.navigationController.navigationBar.tintColor = nil;
}
@end