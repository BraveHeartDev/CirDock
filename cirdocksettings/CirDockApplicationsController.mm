#import <objc/runtime.h>
#import <substrate.h>
#define CirDockFavPLISTPATH @"/var/mobile/Library/Preferences/com.braveheart.cirdock.plist"

#import <AppList/AppList.h>

/*
 #ifndef SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO
 #define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
 #endif
 
 #ifndef __IconFinder__
 #define __IconFinder__
 #define AppSupportPath @"/var/mobile/Library/Application Support/CirDock"
 #define AllAppsDictPath @"/var/mobile/Library/Application Support/CirDock/AllApps.plist"
 #define IconDictPath @"/var/mobile/Library/Application Support/CirDock/IconInfo.plist"
 #define IconPath @"/var/mobile/Library/Application Support/CirDock/Icon.png"
 #define IconParamDictPath @"/var/mobile/Library/Application Support/CirDock/IconParamInfo.plist"
 #endif
 */

@interface UITableViewCellEditingData : NSObject
- (id)reorderSeparatorView:(BOOL)value;
- (id)reorderControl:(BOOL)value;
@end

@interface UITableViewCellLayoutManager : NSObject
- (void)layoutSubviewsOfCell:(id)cell;
@end

@interface UITableViewCell()
{
    id _editingData;
}
- (id)layoutManager;
@end

@interface CirDockEnabledAppCell : UITableViewCell
@end
@implementation CirDockEnabledAppCell
- (void)layoutSubviews
{
    [super layoutSubviews];
    if(self.showsReorderControl)
    {
        UITableViewCellEditingData *editingData = MSHookIvar<UITableViewCellEditingData *>(self, "_editingData");
        [editingData reorderSeparatorView:YES];
        [editingData reorderControl:YES];
        
        [((UITableViewCellLayoutManager*)[self layoutManager]) layoutSubviewsOfCell:self];
    }
}
@end

@interface DisableTableView : UITableView
@end
@implementation DisableTableView
-(NSString*)_titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return @"Disable";
}
@end

@interface PSViewController : UIViewController
@property (nonatomic, retain) UIView *view;
@property (nonatomic, retain) UINavigationController *navigationController;
-(void)viewWillDisappear:(BOOL)animated;
-(void)viewWillAppear:(BOOL)animated;
- (id)initForContentSize:(CGSize)size;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface CirDockApplicationsController : PSViewController <UITableViewDelegate, UITableViewDataSource> {
    
@public
    NSMutableArray *enabledApps, *disabledApps;
    NSMutableDictionary *cachedData, *hiddenData;
}

@property (nonatomic, strong) DisableTableView *tableView;
@property (nonatomic) BOOL didCacheData;

- (id)initForContentSize:(CGSize)size;
- (CGSize)contentSize;
- (id)navigationTitle;
- (void)saveNewOrder;
- (void)updateDisabledAppsArray;
- (void)switchFlipped:(UISwitch *)switchView;
@end

@implementation CirDockApplicationsController
@synthesize didCacheData;

- (void)updateDisabledAppsArray
{
    disabledApps = [[cachedData keysSortedByValueUsingComparator: ^(id obj1, id obj2) {
        if (obj1 == nil)
        {
            return (NSComparisonResult)NSOrderedDescending; //obj1 is > than all rest
        }
        else if(obj2 == nil)
        {
            return (NSComparisonResult)NSOrderedAscending; //obj2 is > than all rest
        }
        
        if (((NSArray*)obj1).count < 2)
        {
            return (NSComparisonResult)NSOrderedDescending; //obj1 is > than all rest
        }
        else if(((NSArray*)obj2).count < 2)
        {
            return (NSComparisonResult)NSOrderedAscending; //obj2 is > than all rest
        }
        
        return [(NSString *)((NSArray *)obj1[1]) caseInsensitiveCompare:(NSString *)((NSArray *)obj2[1])];
    }] mutableCopy];
    
    for(id object in enabledApps)
    {
        [disabledApps removeObject:object];
    }
    
    //Looping backwards (count to 0) to enable the removal of objects since only the objects after i are affected by the removal of object at i
    for(int i = (disabledApps.count-1); i >= 0; i--)
    {
        id object = disabledApps[i];
        if(object == nil || [object isEqual:[NSNull null]])
            [disabledApps removeObjectAtIndex:i];
    }
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

- (void)saveNewOrder
{
    NSMutableDictionary *dict = [[NSDictionary dictionaryWithContentsOfFile:CirDockFavPLISTPATH] mutableCopy];
    if(!dict)
        dict = [[NSMutableDictionary alloc]init];
    
    [dict setObject:enabledApps forKey:@"enabledApps"];
    [dict writeToFile:CirDockFavPLISTPATH atomically:YES];
    
    CFNotificationCenterRef centre = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterPostNotification( centre, (__bridge CFStringRef)@"CirDockAppsChangedNotification", NULL, NULL, YES );
}

- (void)cacheData:(NSTimer*)timer
{
    [timer invalidate];
    
    /*if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.3"))
     {
     CFNotificationCenterRef centre = CFNotificationCenterGetDarwinNotifyCenter();
     CFNotificationCenterPostNotification( centre, (__bridge CFStringRef)@"IconFinderGetAllApps", NULL, NULL, YES );
     NSDictionary *reply = [NSDictionary dictionaryWithContentsOfFile:AllAppsDictPath];
     disabledApps = [reply valueForKey:@"response"];
     
     for(NSString *bID in disabledApps)
     {
     [@{ @"bundleID" : bID, @"iconSize" : @0 } writeToFile:IconParamDictPath atomically:YES];
     CFNotificationCenterPostNotification( centre, (__bridge CFStringRef)@"IconFinderGetIcon", NULL, NULL, YES );
     reply = [NSDictionary dictionaryWithContentsOfFile:IconDictPath];
     [cachedData setValue:@[ [UIImage imageWithContentsOfFile:IconPath], [reply valueForKey:@"response"]] forKey:bID];
     }
     }
     else
     {*/
    /*
     //NSLog(@"Setting Up Connection");
     CFDataRef retData;
     SInt32 messageID = 5; //all application identifiers
     CFTimeInterval timeout = 10.0;
     
     //NSLog(@"Setting Up Port");
     CFMessagePortRef remotePort = CFMessagePortCreateRemote(nil, CFSTR("com.braveheart.cirdock.server"));
     
     //NSLog(@"Sending Request For All Bundle IDs");
     SInt32 status = CFMessagePortSendRequest(remotePort, messageID, NULL, timeout, timeout, kCFRunLoopDefaultMode, &retData);
     if (status == kCFMessagePortSuccess)
     {
     //NSLog(@"Retreived All Bundle IDs");
     disabledApps = [[NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)retData] mutableCopy];
     
     //NSLog(@"Starting To Cache Icons");
     for(NSString *bID in disabledApps) //disabled apps here = all apps
     {
     CFDataRef data;
     messageID = 0; //small icon
     NSData *bundleID = [bID dataUsingEncoding:NSUTF8StringEncoding];
     
     data = CFDataCreate(NULL, (const unsigned char *)[bundleID bytes], [bundleID length]);
     
     //NSLog(@"Getting Icon for B-ID: %@", bID);
     status = CFMessagePortSendRequest(remotePort, messageID, data, timeout, timeout, kCFRunLoopDefaultMode, &retData);
     if (status == kCFMessagePortSuccess)
     {
     NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)retData];
     if(array != nil)
     {
     //NSLog(@"Obtained Icon Data:\n%@", array);
     [cachedData setValue:array forKey:bID];
     }
     //else
     //NSLog(@"Failed To Obtain Icon Data");
     }
     }
     }
     */
    
    NSArray *hiddenApps = [[NSArray alloc] initWithObjects:
                           @"com.apple.AdSheet",
                           @"com.apple.AdSheetPhone",
                           @"com.apple.AdSheetPad",
                           @"com.apple.DataActivation",
                           @"com.apple.DemoApp",
                           @"com.apple.Diagnostics",
                           @"com.apple.fieldtest",
                           @"com.apple.iosdiagnostics",
                           @"com.apple.iphoneos.iPodOut",
                           @"com.apple.TrustMe",
                           @"com.apple.WebSheet",
                           @"com.apple.springboard",
                           @"com.apple.purplebuddy",
                           @"com.apple.datadetectors.DDActionsService",
                           @"com.apple.FacebookAccountMigrationDialog",
                           @"com.apple.iad.iAdOptOut",
                           @"com.apple.ios.StoreKitUIService",
                           @"com.apple.TextInput.kbd",
                           @"com.apple.MailCompositionService",
                           @"com.apple.mobilesms.compose",
                           @"com.apple.quicklook.quicklookd",
                           @"com.apple.ShoeboxUIService",
                           @"com.apple.social.remoteui.SocialUIService",
                           @"com.apple.WebViewService",
                           @"com.apple.gamecenter.GameCenterUIService",
                           @"com.apple.appleaccount.AACredentialRecoveryDialog",
                           @"com.apple.CompassCalibrationViewService",
                           @"com.apple.WebContentFilter.remoteUI.WebContentAnalysisUI",
                           @"com.apple.PassbookUIService",
                           @"com.apple.uikit.PrintStatus",
                           @"com.apple.Copilot",
                           @"com.apple.MusicUIService",
                           @"com.apple.AccountAuthenticationDialog",
                           @"com.apple.MobileReplayer",
                           @"com.apple.SiriViewService",
                           @"com.apple.TencentWeiboAccountMigrationDialog",
                           // iOS 8
                           @"com.apple.AskPermissionUI",
                           @"com.apple.CoreAuthUI",
                           @"com.apple.family",
                           @"com.apple.mobileme.fmip1",
                           @"com.apple.GameController",
                           @"com.apple.HealthPrivacyService",
                           @"com.apple.InCallService",
                           @"com.apple.mobilesms.notification",
                           @"com.apple.PhotosViewService",
                           @"com.apple.PreBoard",
                           @"com.apple.PrintKit.Print-Center",
                           @"com.apple.share",
                           @"com.apple.SharedWebCredentialViewService",
                           @"com.apple.webapp",
                           @"com.apple.webapp1",
                           nil];
    
    ALApplicationList *appList = [ALApplicationList sharedApplicationList];
    NSDictionary *identifiers = [appList applicationsFilteredUsingPredicate:nil];
    for(NSString *bID in [identifiers allKeys])
    {
        UIImage *image = [appList iconOfSize:ALApplicationIconSizeSmall forDisplayIdentifier:bID];
        NSString *displayName = identifiers[bID];
        
        NSArray *cellData = @[(image == nil)?[NSNull null]:image, (displayName == nil)?bID:displayName];
        if([hiddenApps containsObject:bID])
            [hiddenData setValue:cellData forKey:bID];
        else
            [cachedData setValue:cellData forKey:bID];
    }
    
    //NSLog(@"Completed All Requests and Sorted List");
    //}
    [self updateDisabledAppsArray];
    didCacheData = YES;
    [_tableView setEditing:YES animated:NO];
    [_tableView reloadData];
}

- (void)switchFlipped:(UISwitch *)switchView
{
    if(switchView.isOn)
    {
        for(NSString *key in [hiddenData allKeys])
        {
            [cachedData setValue:hiddenData[key] forKey:key];
        }
    }
    else
    {
        for(NSString *key in [hiddenData allKeys])
        {
            [cachedData setValue:nil forKey:key];
        }
    }
    [self updateDisabledAppsArray];
    didCacheData = YES;
    [_tableView setEditing:YES animated:NO];
    [_tableView reloadData];
}

- (id)initForContentSize:(CGSize)size {
    
    if ([[PSViewController class] instancesRespondToSelector:@selector(initForContentSize:)])
        self = [super initForContentSize:size];
    else
        self = [super init];
    
    if (self)
    {
        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 51, 31)];
        [switchView addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
        switchView.on = NO;
        switchView.onTintColor = [UIColor colorWithRed:1 green:80.f/255.f blue:70.f/255.f alpha:1];
        ((UINavigationItem*)self.navigationItem).rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:switchView];
        
        
        CGRect frame;
        frame.origin = (CGPoint){0, 0};
        frame.size = self.view.bounds.size;
        
        _tableView = [[DisableTableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
        
        cachedData = [[NSMutableDictionary alloc]init];
        hiddenData = [[NSMutableDictionary alloc]init];
        
        NSMutableDictionary *dict = [[NSDictionary dictionaryWithContentsOfFile:CirDockFavPLISTPATH] mutableCopy];
        if(dict)
        {
            enabledApps = [[dict objectForKey:@"enabledApps"] mutableCopy];
        }
        
        if(enabledApps == nil)
            enabledApps = [[NSMutableArray alloc]init];
        if(disabledApps == nil)
            disabledApps = [[NSMutableArray alloc]init];
        
        [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(cacheData:) userInfo:nil repeats:NO];
        
        [_tableView setDataSource:self];
        [_tableView setDelegate:self];
        [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self.view addSubview:_tableView];
    }
    return self;
}

- (UITableView *)table
{
    return _tableView;
}

- (CGSize)contentSize
{
    return [self.view frame].size;
}

- (id)navigationTitle
{
    return @"Enabled Applications";
}

- (NSString *)title
{
    return @"Enabled Applications";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView
shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!didCacheData)
        return UITableViewCellEditingStyleNone;
    
    if(indexPath.section == 0)
        return UITableViewCellEditingStyleDelete;
    else
        return UITableViewCellEditingStyleInsert;
    
    return UITableViewCellEditingStyleNone;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return [NSString stringWithFormat:@"Enabled Applications - %lu", (unsigned long)enabledApps.count];
    else
        return @"Disabled Applications";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if(section == 0)
        return @"Drag the enabled cells' reorder controls to reorder them as you wish. Any changes will inflict upon the dock immediately.";
    
    return @"";
}

- (NSIndexPath *)tableView:(UITableView *)tableView
targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if(sourceIndexPath.section == proposedDestinationIndexPath.section && sourceIndexPath.section == 0)
        return proposedDestinationIndexPath;
    else
        return sourceIndexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    BOOL isOS7 = kCFCoreFoundationVersionNumber >= 847.20;
    if (isOS7)
    {
        if(!UIInterfaceOrientationIsLandscape([self interfaceOrientation]))
            _tableView.contentInset = UIEdgeInsetsMake(64.0f, 0.0f, 0.0f, 0.0f);
        else
            _tableView.contentInset = UIEdgeInsetsMake(32.0f, 0.0f, 0.0f, 0.0f);
    }
    
    if(!didCacheData)
        return 1;
    
    if(section == 0)
        return [enabledApps count];
    else
        return [disabledApps count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CirDockEnabledAppCellID";
    CirDockEnabledAppCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
        cell = [[CirDockEnabledAppCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    if(!didCacheData)
    {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        spinner.frame = CGRectMake(0, 0, 24, 24);
        cell.accessoryView = spinner;
        [spinner startAnimating];
        cell.textLabel.text = (indexPath.section == 0)?@"Loading Enabled Applications...":@"Loading Disabled Applications...";
    }
    else
    {
        cell.showsReorderControl = YES;
        
        id image;
        NSString *title;
        
        if(indexPath.section == 0)
        {
            NSArray *iconArray = cachedData[enabledApps[indexPath.row]];
            if(iconArray.count == 2)
            {
                image = iconArray[0];
                title = iconArray[1];
            }
            else
            {
                image = nil;
                title = @"Unknown";
            }
        }
        else
        {
            NSArray *iconArray = cachedData[disabledApps[indexPath.row]];
            if(iconArray.count == 2)
            {
                image = iconArray[0];
                title = iconArray[1];
            }
            else
            {
                image = nil;
                title = @"Unknown";
            }
        }
        
        cell.imageView.image = ([image isEqual:[NSNull null]])?nil:image;
        cell.textLabel.text = title;
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView
canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    id data;
    if(fromIndexPath.section == 0)
    {
        data = enabledApps[fromIndexPath.row];
        [enabledApps removeObject:data];
    }
    else
    {
        data = disabledApps[fromIndexPath.row];
        [disabledApps removeObject:data];
    }
    
    if(toIndexPath.section == 0)
    {
        [enabledApps insertObject:data atIndex:toIndexPath.row];
    }
    else
    {
        [disabledApps insertObject:data atIndex:toIndexPath.row];
    }
    
    [self saveNewOrder];
    [[self table] reloadData];
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        [enabledApps removeObjectAtIndex:indexPath.row];
        
        [self updateDisabledAppsArray];
        [self saveNewOrder];
        [_tableView reloadData];
    }
    else if(editingStyle == UITableViewCellEditingStyleInsert)
    {
        id object = disabledApps[indexPath.row];
        [enabledApps addObject:object];
        
        [self updateDisabledAppsArray];
        [self saveNewOrder];
        [_tableView reloadData];
    }
}

@end