#import <objc/runtime.h>
#import <substrate.h>
#define CirDockPLISTPATH @"/var/mobile/Library/Preferences/com.braveheart.cirdock.plist"

enum HoldSection {
    HoldDefault = 0,
    HoldBanners,
    HoldFavorites,
    HoldBannersAndDefault,
    HoldRunningApps,
    SectionsCount
};

@interface PSListController: UIViewController
@end


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

@interface CirDockHoldAppCell : UITableViewCell
@end
@implementation CirDockHoldAppCell
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

@interface PSViewController : UIViewController
@property (nonatomic, retain) UIView *view;
@property (nonatomic, retain) UINavigationController *navigationController;
-(void)viewWillDisappear:(BOOL)animated;
-(void)viewWillAppear:(BOOL)animated;
- (id)initForContentSize:(CGSize)size;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)pushController:(id)controller animate:(BOOL)animate;
@end

@interface CirDockFavoritesController : PSViewController <UITableViewDelegate, UITableViewDataSource>
@end

@interface CirDockBadgeController : PSListController
@end

@interface CirDockHoldController : PSViewController <UITableViewDelegate, UITableViewDataSource> {
    
    UITableView *_tableView;
@public
    NSMutableArray *enabledLongHold;
}

- (id)initForContentSize:(CGSize)size;
- (CGSize)contentSize;
- (id)navigationTitle;
- (void)saveNewOrder;
@end

@implementation CirDockHoldController

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
    NSMutableDictionary *dict = [[NSDictionary dictionaryWithContentsOfFile:CirDockPLISTPATH] mutableCopy];
    if(!dict)
        dict = [[NSMutableDictionary alloc]init];
    
    [dict setObject:enabledLongHold forKey:@"enabledLongHold"];
    [dict writeToFile:CirDockPLISTPATH atomically:YES];
    
    CFNotificationCenterRef centre = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterPostNotification( centre, (__bridge CFStringRef)@"CirDockAppsChangedNotification", NULL, NULL, YES );
}

- (id)initForContentSize:(CGSize)size {
    
    if ([[PSViewController class] instancesRespondToSelector:@selector(initForContentSize:)])
        self = [super initForContentSize:size];
    else
        self = [super init];
    
    if (self)  {
        
        CGRect frame;
        frame.origin = (CGPoint){0, 0};
        frame.size = self.view.bounds.size;
        
        _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
        [_tableView setEditing:YES animated:NO];
        _tableView.allowsSelectionDuringEditing = YES;
        
        NSMutableDictionary *dict = [[NSDictionary dictionaryWithContentsOfFile:CirDockPLISTPATH] mutableCopy];
        if(dict)
            enabledLongHold = [[dict objectForKey:@"enabledLongHold"] mutableCopy];
        
        if(enabledLongHold == nil || enabledLongHold.count == 0)
            enabledLongHold = [@[@0] mutableCopy];
        
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
    return @"Hold Actions";
}

- (NSString *)title
{
    return @"Hold Actions";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
    if(cell.tag == HoldFavorites)
    {
        [self.navigationController pushViewController:[[CirDockFavoritesController alloc]initForContentSize:self.view.frame.size] animated:YES];
    }
    else if (cell.tag == HoldBanners)
    {
        [self.navigationController pushViewController:[[CirDockBadgeController alloc]init] animated:YES];
    }
    else if(cell.tag == HoldBannersAndDefault)
    {
        [self.navigationController pushViewController:[[CirDockBadgeController alloc]init] animated:YES];
    }
    else if(cell.tag == HoldRunningApps)
    {
        ;
    }
}

- (BOOL)tableView:(UITableView *)tableView
shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return @"Enabled Actions";
    else
        return @"Disabled Actions";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if(section == 1)
        return @"You can select some cells to configure their settings such as the favorite applications, etc...";
    else
        return @"";
}

- (NSIndexPath *)tableView:(UITableView *)tableView
targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if(!(sourceIndexPath.section == 0 && sourceIndexPath.row == 0) && !(proposedDestinationIndexPath.section == 0 && proposedDestinationIndexPath.row == 0))
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
    
    if(section == 0)
        return enabledLongHold.count;
    else
        return SectionsCount - enabledLongHold.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"CirDockHoldAppCell-ID";
    CirDockHoldAppCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if(cell == nil)
    {
        cell = [[CirDockHoldAppCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    if(!(indexPath.section == 0 && indexPath.row == 0))
        cell.showsReorderControl = YES;
    
    NSMutableArray *allHoldSections = [@[@(HoldDefault), @(HoldBanners), @(HoldFavorites), @(HoldBannersAndDefault), @(HoldRunningApps)] mutableCopy];
    for(NSNumber *i in enabledLongHold)
    {
        [allHoldSections removeObject:i];
    }
    
    if (indexPath.section == 0)
    {
        cell.tag = [enabledLongHold[indexPath.row] intValue];
    }
    else
    {
        cell.tag = [allHoldSections[indexPath.row] intValue];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    switch (cell.tag)
    {
        case HoldDefault:
        {
            cell.textLabel.text = @"Default (OFF)";
            NSData *imgData = [[NSData alloc] initWithContentsOfFile:@"/Library/PreferenceBundles/CirDockSettings.bundle/Default.jpg"];
            UIImage *img = [[UIImage alloc] initWithData:imgData];
            cell.imageView.image = img;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        }
        case HoldBanners:
        {
            cell.textLabel.text = @"Display Badged Items";
            NSData *imgData = [[NSData alloc] initWithContentsOfFile:@"/Library/PreferenceBundles/CirDockSettings.bundle/Badged.jpg"];
            UIImage *img = [[UIImage alloc] initWithData:imgData];
            cell.imageView.image = img;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case HoldFavorites:
        {
            cell.textLabel.text = @"Display Favorites";
            NSData *imgData = [[NSData alloc] initWithContentsOfFile:@"/Library/PreferenceBundles/CirDockSettings.bundle/Favorited.jpg"];
            UIImage *img = [[UIImage alloc] initWithData:imgData];
            cell.imageView.image = img;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case HoldBannersAndDefault:
        {
            cell.textLabel.text = @"Display Badged Items and Default";
            NSData *imgData = [[NSData alloc] initWithContentsOfFile:@"/Library/PreferenceBundles/CirDockSettings.bundle/BadgedDefault.jpg"];
            UIImage *img = [[UIImage alloc] initWithData:imgData];
            cell.imageView.image = img;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case HoldRunningApps:
        {
            cell.textLabel.text = @"Display Running Apps";
            NSData *imgData = [[NSData alloc] initWithContentsOfFile:@"/Library/PreferenceBundles/CirDockSettings.bundle/Running.jpg"];
            UIImage *img = [[UIImage alloc] initWithData:imgData];
            cell.imageView.image = img;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        default:
            break;
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView
canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && indexPath.row == 0)
        return NO;
    
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSNumber *data;
    if(fromIndexPath.section == 0)
        data = enabledLongHold[fromIndexPath.row];
    else
    {
        NSMutableArray *allHoldSections = [@[@(HoldDefault), @(HoldBanners), @(HoldFavorites), @(HoldBannersAndDefault), @(HoldRunningApps)] mutableCopy];
        for(NSNumber *i in enabledLongHold)
        {
            [allHoldSections removeObject:i];
        }
        data = allHoldSections[fromIndexPath.row];
    }
    
    [enabledLongHold removeObject:data];
    
    if(toIndexPath.section == 0)
        [enabledLongHold insertObject:data atIndex:toIndexPath.row];
				
    [self saveNewOrder];
    [[self table] reloadData];
}

@end
