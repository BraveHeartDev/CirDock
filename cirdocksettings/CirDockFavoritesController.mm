#import <objc/runtime.h>
#import <substrate.h>
#import "NSString+Emojize.h"
#define CirDockFavPLISTPATH @"/var/mobile/Library/Preferences/com.braveheart.cirdock.plist"

#import <AppList/AppList.h>

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

@interface CirDockFavAppCell : UITableViewCell
@end
@implementation CirDockFavAppCell
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
@end

@interface CirDockFavoritesController : PSViewController <UITableViewDelegate, UITableViewDataSource> {
    
    UITableView *_tableView;
@public
    NSMutableArray *favApps, *unfavApps;
    NSMutableDictionary *cachedData;
}
@property (nonatomic) BOOL didCacheData;

- (id)initForContentSize:(CGSize)size;
- (CGSize)contentSize;
- (id)navigationTitle;
- (void)saveNewOrder;
@end

@implementation CirDockFavoritesController
@synthesize didCacheData;

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
    
    [dict setObject:favApps forKey:@"favApps"];
    [dict writeToFile:CirDockFavPLISTPATH atomically:YES];
    
    CFNotificationCenterRef centre = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterPostNotification( centre, (__bridge CFStringRef)@"CirDockAppsChangedNotification", NULL, NULL, YES );
}

- (void)cacheData:(NSTimer*)timer
{
    [timer invalidate];
    
    NSMutableDictionary *dict = [[NSDictionary dictionaryWithContentsOfFile:CirDockFavPLISTPATH] mutableCopy];
    if(dict)
        unfavApps = [[dict objectForKey:@"enabledApps"] mutableCopy];
    
    ALApplicationList *appList = [ALApplicationList sharedApplicationList];
    NSDictionary *identifiers = [appList applicationsFilteredUsingPredicate:nil];
    for(NSString *bundleID in unfavApps)
    {
        UIImage *image = [appList iconOfSize:ALApplicationIconSizeSmall forDisplayIdentifier:bundleID];
        NSString *displayName = identifiers[bundleID];
        
        NSArray *cellData = @[(image == nil)?[NSNull null]:image, (displayName == nil)?bundleID:displayName];
        [cachedData setValue:cellData forKey:bundleID];
    }
    
    for(id object in favApps)
    {
        [unfavApps removeObject:object];
    }
    
    didCacheData = YES;
    [_tableView setEditing:YES animated:NO];
    [_tableView reloadData];
}

- (id)initForContentSize:(CGSize)size {
    
    if ([[PSViewController class] instancesRespondToSelector:@selector(initForContentSize:)])
        self = [super initForContentSize:size];
    else
        self = [super init];
    
    if (self)  {
        cachedData = [[NSMutableDictionary alloc]init];
        
        CGRect frame;
        frame.origin = (CGPoint){0, 0};
        frame.size = self.view.bounds.size;
        
        _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
        
        NSMutableDictionary *dict = [[NSDictionary dictionaryWithContentsOfFile:CirDockFavPLISTPATH] mutableCopy];
        if(dict)
        {
            favApps = [[dict objectForKey:@"favApps"] mutableCopy];
        }
        
        if(favApps == nil)
            favApps = [[NSMutableArray alloc]init];
        if(unfavApps == nil)
            unfavApps = [[NSMutableArray alloc]init];
        
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
    return @"Favorite Applications";
}

- (NSString *)title
{
    return @"Favorite Applications";
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
    return UITableViewCellEditingStyleNone;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return @"\u2606 Favorited \u2606";
    else
        return [@":thumbsdown: Un-favorited :thumbsdown:" emojizedString];
}

- (NSIndexPath *)tableView:(UITableView *)tableView
targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    return proposedDestinationIndexPath;
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
        return [favApps count];
    else
        return [unfavApps count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CirDockFavAppCell-ID";
    CirDockFavAppCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
        cell = [[CirDockFavAppCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    
    
    if(!didCacheData)
    {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        spinner.frame = CGRectMake(0, 0, 24, 24);
        cell.accessoryView = spinner;
        [spinner startAnimating];
        cell.textLabel.text = (indexPath.section == 0)?@"Loading Favorited Applications...":@"Loading Unfavorited Applications...";
    }
    else
    {
        cell.showsReorderControl = YES;
        cell.imageView.image = nil;
        cell.textLabel.text = @"";
        
        NSString *bID = @"";
        if(indexPath.section == 0)
        {
            bID = favApps[indexPath.row];
        }
        else
        {
            bID = unfavApps[indexPath.row];
        }
        
        NSArray *dataArray = cachedData[bID];
        if(dataArray)
        {
            cell.imageView.image = [dataArray[0] isKindOfClass:[NSNull class]]?nil:dataArray[0];
            cell.textLabel.text = dataArray[1];
        }
        else
        {
            ALApplicationList *appList = [ALApplicationList sharedApplicationList];
            NSDictionary *identifiers = [appList applicationsFilteredUsingPredicate:nil];
            for(NSString *bundleID in [identifiers allKeys])
            {
                UIImage *image = [appList iconOfSize:ALApplicationIconSizeSmall forDisplayIdentifier:bundleID];
                NSString *displayName = identifiers[bundleID];
                
                NSArray *cellData = @[(image == nil)?[NSNull null]:image, (displayName == nil)?bundleID:displayName];
                
                cell.imageView.image = cellData[0];
                cell.textLabel.text = cellData[1];
                [cachedData setValue:cellData forKey:bundleID];
            }
        }
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
    NSNumber *data;
    if(fromIndexPath.section == 0)
    {
        data = favApps[fromIndexPath.row];
        [favApps removeObject:data];
    }
    else
    {
        data = unfavApps[fromIndexPath.row];
        [unfavApps removeObject:data];
    }
    
    if(toIndexPath.section == 0)
    {
        [favApps insertObject:data atIndex:toIndexPath.row];
    }
    else
    {
        [unfavApps insertObject:data atIndex:toIndexPath.row];
    }
    
    [self saveNewOrder];
    [[self table] reloadData];
}

@end
