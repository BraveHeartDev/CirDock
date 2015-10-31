#import "PSIECell.h"
#import "UIAlertView+Blocks.h"

#import <AppList/AppList.h>

#define settingsPath @"/var/mobile/Library/CirDockSettings.CDS"
#define plistPath @"/var/mobile/Library/Preferences/com.braveheart.cirdock.plist"

void writeSettings(NSDictionary *dict)
{
    if(![dict writeToFile:settingsPath atomically:YES])
    {
        [UIAlertView showWithTitle:@"Export Error" message:@"Please notify the developer of this error" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
    }
    else
    {
        [UIAlertView showWithTitle:@"Export Succeeded" message:[NSString stringWithFormat:@"The file has been successfully exported to: %@", settingsPath] cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
    }
}

@implementation PSIECell
@synthesize importBtn, exportBtn;

- (void)Import
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:settingsPath];
    if(dict)
    {
        ALApplicationList *appList = [ALApplicationList sharedApplicationList];
        NSDictionary *identifiers = [appList applicationsFilteredUsingPredicate:nil];
        NSArray *installedApps = [identifiers allKeys];
        
        
        NSArray *cirDockApps = [dict valueForKey:@"enabledApps"];
        
        NSArray *installedCirDockApps = [cirDockApps filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF IN %@", installedApps]];
        
        NSArray *favoritedApps = [dict valueForKey:@"favApps"];
        favoritedApps = [favoritedApps filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF IN %@", installedCirDockApps]];
        
        int notInstalledApps = cirDockApps.count - installedCirDockApps.count;
        
        if(notInstalledApps > 0)
        {
            [dict setObject:installedCirDockApps forKey:@"enabledApps"];
            [dict setObject:favoritedApps forKey:@"favApps"];
        }
        
        if(![dict writeToFile:plistPath atomically:YES])
        {
            [UIAlertView showWithTitle:@"Import Error" message:@"Please notify the developer of this error: Unable to complete import changes!" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
        }
        else
        {
            CFNotificationCenterRef centre = CFNotificationCenterGetDarwinNotifyCenter();
            CFNotificationCenterPostNotification( centre, (__bridge CFStringRef)@"CirDockCarouselChangeNotification", NULL, NULL, YES );
            CFNotificationCenterPostNotification( centre, (__bridge CFStringRef)@"CirDockAppsChangedNotification", NULL, NULL, YES );
            CFNotificationCenterPostNotification( centre, (__bridge CFStringRef)@"CirDockBadgeChangeNotification", NULL, NULL, YES );
            CFNotificationCenterPostNotification( centre, (__bridge CFStringRef)@"CirDockColorChangeNotification", NULL, NULL, YES );
            CFNotificationCenterPostNotification( centre, (__bridge CFStringRef)@"CirDockLabelChangeNotification", NULL, NULL, YES );
            
            [UIAlertView showWithTitle:@"Import Succeeded" message:[NSString stringWithFormat:@"Changes will take effect immediately.\n There were %i applications found that haven't been installed on this device so they have been removed from the list.", notInstalledApps] cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
        }
    }
    else
        [UIAlertView showWithTitle:@"Import Error" message:[NSString stringWithFormat:@"Settings file not found at %@", settingsPath] cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
}

- (void)Export
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    if(dict)
    {
        NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:settingsPath];
        if(settingsDict)
        {
            NSArray *differences = [self settingsFilesDifferencesWithDict:dict andDict:settingsDict];
            if(differences.count > 0)
            {
                NSString *difString = [differences componentsJoinedByString:@"\n"];
                [UIAlertView showWithTitle:@"Overwrite File?" message:[NSString stringWithFormat:@"A current settings file has been found at the export location. It has the following differences with the current settings to be exported:\n\n%@\n\nDo you want to overwrite the old file with the current settings?", difString] cancelButtonTitle:@"No" otherButtonTitles:@[@"Overwrite"] tapBlock:^(UIAlertView * alertView, NSInteger buttonIndex){
                    if([[alertView buttonTitleAtIndex:buttonIndex]isEqual:@"Overwrite"])
                    {
                        writeSettings(dict);
                    }
                }];
            }
            else
            {
                writeSettings(dict);
            }
        }
        else
        {
            writeSettings(dict);
        }
    }
    else
        [UIAlertView showWithTitle:@"Export Error" message:[NSString stringWithFormat:@"There were no changed settings found other than the default settings!"] cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
}

- (NSArray*)settingsFilesDifferencesWithDict:(NSDictionary*)dict1 andDict:(NSDictionary*)dict2
{
    NSMutableArray *differences = [[NSMutableArray alloc]init];
    if(![[dict1 valueForKey:@"GlowColor"] isEqual:[dict2 valueForKey:@"GlowColor"]])
    {
        [differences addObject:@"- The highlight color in both settings is different."];
    }
    if(![[dict1 valueForKey:@"badgeAllApps"] isEqual:[dict2 valueForKey:@"badgeAllApps"]])
    {
        [differences addObject:@"- The displaying of all badges applications is different in both settings."];
    }
    if(![[dict1 valueForKey:@"enabledApps"] isEqual:[dict2 valueForKey:@"enabledApps"]])
    {
        [differences addObject:@"- The enabled applications in both settings are different."];
    }
    if(![[dict1 valueForKey:@"enabledLongHold"] isEqual:[dict2 valueForKey:@"enabledLongHold"]])
    {
        [differences addObject:@"- The enabled long hold actions in both settings are different."];
    }
    if(![[dict1 valueForKey:@"favApps"] isEqual:[dict2 valueForKey:@"favApps"]])
    {
        [differences addObject:@"- The favorited applications in both settings are different."];
    }
    if(![[dict1 valueForKey:@"isGlowBGOn"] isEqual:[dict2 valueForKey:@"isGlowBGOn"]])
    {
        [differences addObject:@"- Whether or not to highlight running applications is different in both settings."];
    }
    if(![[dict1 valueForKey:@"kListValue"] isEqual:[dict2 valueForKey:@"kListValue"]])
    {
        [differences addObject:@"- The carousel type in both settings is different."];
    }
    if(![[dict1 valueForKey:@"removeLabels"] isEqual:[dict2 valueForKey:@"removeLabels"]])
    {
        [differences addObject:@"- The removal of icon labels in both settings is different."];
    }
    if(![[dict1 valueForKey:@"removeBadges"] isEqual:[dict2 valueForKey:@"removeBadges"]])
    {
        [differences addObject:@"- The removal of icon badges in both settings is different."];
    }
    if(![[dict1 valueForKey:@"removeActionLabel"] isEqual:[dict2 valueForKey:@"removeActionLabel"]])
    {
        [differences addObject:@"- The removal of the action label in both settings is different."];
    }
    if(![[dict1 valueForKey:@"iconScale-portrait"] isEqual:[dict2 valueForKey:@"iconScale-portrait"]] || ![[dict1 valueForKey:@"iconScale-landscape"] isEqual:[dict2 valueForKey:@"iconScale-landscape"]])
    {
        [differences addObject:@"- The icon scale in both settings is different."];
    }
    if(![[dict1 valueForKey:@"iconSpacing-portrait"] isEqual:[dict2 valueForKey:@"iconSpacing-portrait"]] || ![[dict1 valueForKey:@"iconSpacing-landscape"] isEqual:[dict2 valueForKey:@"iconSpacing-landscape"]])
    {
        [differences addObject:@"- The icon spacing in both settings is different."];
    }
    if(![[dict1 valueForKey:@"maxVisIcons-portrait"] isEqual:[dict2 valueForKey:@"maxVisIcons-portrait"]] || ![[dict1 valueForKey:@"maxVisIcons-landscape"] isEqual:[dict2 valueForKey:@"maxVisIcons-landscape"]])
    {
        [differences addObject:@"- The maximum visible icons count in both settings is different."];
    }
    if(![[dict1 valueForKey:@"dockHeight-portrait"] isEqual:[dict2 valueForKey:@"dockHeight-portrait"]] || ![[dict1 valueForKey:@"dockHeight-landscape"] isEqual:[dict2 valueForKey:@"dockHeight-landscape"]])
    {
        [differences addObject:@"- The dock height in both settings is different."];
    }

    return differences;
}

-(id)initWithStyle:(int)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)spec {
    
    //call the super class's method to create the switch cell
    self = [super initWithStyle:style reuseIdentifier:identifier specifier:spec];
    
    if (self)
    {
        importBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [importBtn addTarget:self action:@selector(Import) forControlEvents:UIControlEventTouchUpInside];
        [importBtn setTitle:@"Import" forState:UIControlStateNormal];
        importBtn.frame = CGRectMake(0, 0, self.bounds.size.width/2, self.bounds.size.height);
        importBtn.layer.borderWidth = 1;
        importBtn.layer.cornerRadius = 0;
        [importBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        importBtn.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth);
        [self addSubview:importBtn];
        
        exportBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [exportBtn addTarget:self action:@selector(Export) forControlEvents:UIControlEventTouchUpInside];
        [exportBtn setTitle:@"Export" forState:UIControlStateNormal];
        exportBtn.frame = CGRectMake(self.bounds.size.width/2, 0, self.bounds.size.width/2, self.bounds.size.height);
        exportBtn.layer.borderWidth = 1;
        exportBtn.layer.cornerRadius = 0;
        [exportBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        exportBtn.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth);
        [self addSubview:exportBtn];
    }
    return self;
}

@end