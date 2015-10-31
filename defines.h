#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface SBApplication : NSObject
{
    NSString* _bundleIdentifier;
}
-(BOOL)icon:(id)icon launchFromLocation:(int)location;
-(void)activate;
-(id)displayIdentifier;
-(id)bundleIdentifier;
-(NSString*)displayName;
-(void)setBadge:(id)badge;
-(id)badgeNumberOrString;
-(NSString*)pathForSmallIcon;
-(NSString*)pathForIcon;
@end

@interface SBApplicationController : NSObject
+(SBApplicationController*)sharedInstance;
+(SBApplicationController*)sharedInstanceIfExists;
-(SBApplication*)applicationWithPid:(int)pid;
-(SBApplication*)applicationWithDisplayIdentifier:(id)displayIdentifier;
-(SBApplication*)applicationWithBundleIdentifier:(id)bundleIdentifier;
-(NSArray*)applicationsWithPid:(int)pid;
-(NSArray*)applicationsWithBundleIdentifier:(id)bundleIdentifier;
-(id)allApplications;
-(id)allDisplayIdentifiers;
-(id)allBundleIdentifiers;
@end

@interface SBIcon : NSObject
- (UIImage *)getIconImage:(int)img;
- (UIImage *)smallIcon;
-(SBApplication*)application;
- (UIImage *)icon;
@end

@interface SBApplicationIcon : SBIcon
-(SBApplicationIcon*)initWithApplication:(SBApplication*)application;
-(int)badgeValue;
@end

@interface SBIconModel : NSObject
@property(retain, nonatomic) NSDictionary* leafIconsByIdentifier;

+ (SBIconModel *)sharedInstance;
- (SBApplicationIcon*)expectedIconForDisplayIdentifier:(NSString*)identifier;
- (SBApplicationIcon*)applicationIconForDisplayIdentifier:(NSString*)identifier;
- (SBApplicationIcon*)applicationIconForBundleIdentifier:(NSString*)identifier;
- (SBIcon*)iconForDisplayIdentifier:(NSString*)identifier;
- (NSArray *)icons; //Array of SBIcon's
-(void)addIcon:(id)icon;
-(void)removeIconForIdentifier:(id)identifier;
-(void)_saveIconState;
-(void)layout;
@end

@interface SBDockIconListView : UIView
-(SBIconModel *)model;
-(void)setModel:(SBIconModel *)model;
@end

@interface SBRootIconListView : UIView
-(void)insertIcon:(id)icon atIndex:(NSUInteger)index moveNow:(BOOL)moveNow;
@end

@interface SBDockView : UIView
{
    SBDockIconListView *_iconListView;
}
@end

@interface SBFolderController : UIViewController
-(int)_indexOfIconListForIcon:(id)icon;
@end

@interface SBIconController : UIViewController
+(SBIconController*)sharedInstance;
-(void)_launchIcon:(id)icon;
-(SBIconModel *)model;
-(void)addNewIconToDesignatedLocation:(id)designatedLocation animate:(BOOL)animate scrollToList:(BOOL)list saveIconState:(BOOL)state;
-(void)addNewIconsToDesignatedLocations:(id)designatedLocations saveIconState:(BOOL)state;
-(void)removeIcon:(id)icon compactFolder:(BOOL)folder;
-(int)currentFolderIconListIndex;
-(int)currentIconListIndex;
-(id)currentFolderIconList;
-(id)dockListView;
-(id)currentRootIconList;
-(id)folderIconListAtIndex:(unsigned)index;
-(id)rootIconListAtIndex:(int)index;
-(void)insertIcon:(id)icon atIndexPath:(NSUInteger)index moveNow:(BOOL)moveNow;
-(SBFolderController *)_currentFolderController;
- (void)_revealMenuForIconView:(id)arg1 presentImmediately:(BOOL)arg2;
@end

@interface SBIconListView : UIView {
}
+(unsigned)maxVisibleIcons;
+(unsigned)maxIcons;
+(unsigned)iconColumnsForInterfaceOrientation:(int)interfaceOrientation;
+(unsigned)maxVisibleIconRowsInterfaceOrientation:(int)orientation;
+(unsigned)iconRowsForInterfaceOrientation:(int)interfaceOrientation;
+(int)rotationAnchor;
-(void)removeIcon:(id)icon;
-(void)removeIconAtIndex:(unsigned)index;
-(id)removedIcons;
-(id)insertIcon:(id)icon atIndex:(unsigned)index moveNow:(BOOL)now;
-(id)insertIcon:(id)icon atIndex:(unsigned)index moveNow:(BOOL)now pop:(BOOL)pop;
-(id)placeIcon:(id)icon atIndex:(unsigned)index moveNow:(BOOL)now pop:(BOOL)pop;
-(unsigned)iconRowsForSpacingCalculation;
-(unsigned)iconsInRowForSpacingCalculation;
-(unsigned)iconColumnsForCurrentOrientation;
-(unsigned)iconRowsForCurrentOrientation;
-(id)model;
-(void)setModel:(id)model;
-(void)dealloc;
-(id)initWithModel:(id)model orientation:(int)orientation viewMap:(id)map;
-(unsigned)firstFreeSlotOrLastSlotIndexForType:(int)type;
-(unsigned)firstFreeSlotOrLastSlotIndex;
-(unsigned)firstFreeSlotIndexForType:(int)type;
-(unsigned)firstFreeSlotIndex;
-(BOOL)containsIcon:(id)icon;
@end

@interface SBIconImageView : UIView
- (UIImage *)contentsImage;
@end

@interface SBIconView : UIImageView
@property (nonatomic, retain) SBApplicationIcon *icon;
-(SBIconView*)initWithContentType:(unsigned int)type;
-(SBIconView*)initWithDefaultSize;
-(SBIconImageView *)_iconImageView;
- (void)addIcon:(SBIcon *)icon;
- (void)removeIconForIdentifier:(id)identifier;
- (void)_handleSecondHalfLongPressTimer:(id)arg1;
@end

@interface SBIconViewMap : NSObject
+(SBIconViewMap *)homescreenMap;
-(SBIconModel *)iconModel;
@end

@interface SpringBoard : NSObject
-(UIInterfaceOrientation)activeInterfaceOrientation;
-(BOOL)launchApplicationWithIdentifier:(id)identifier suspended:(BOOL)suspended;
-(NSArray*)_accessibilityRunningApplications;
- (void)setWantsOrientationEvents:(BOOL)wantsEvents;
- (void)updateOrientationAndAccelerometerSettings;
@end

@interface SBRootFolderController : UIViewController
@end

@interface FBApplicationInfo : NSObject
@property (nonatomic, retain) NSString *bundleIdentifier;
@end

@interface FBProcess : NSObject
@property (nonatomic, retain) FBApplicationInfo *applicationInfo;
@end

@interface SBRootFolderView : UIView
-(void)_layoutSubviews;
@property(readonly, copy, nonatomic) NSArray* iconListViews;
@end

@interface SBAccelerometerInterface : NSObject
+ (SBAccelerometerInterface *)sharedInstance;
- (NSArray *)valueForKey:(id)key;
- (void)updateSettings;
@end

@interface SBAccelerometerClient : NSObject
@property (nonatomic) float updateInterval;
@end

@interface SBOrientationLockManager : NSObject {
    NSMutableSet *_lockOverrideReasons;
    UIInterfaceOrientation _userLockedOrientation;
}
+ (SBOrientationLockManager *)sharedInstance;
- (void)restoreStateFromPrefs;
- (id)init;
- (void)dealloc;
- (void)lock;
- (void)lock:(UIInterfaceOrientation)lock;
- (void)unlock;
- (BOOL)isLocked;
- (UIInterfaceOrientation)userLockOrientation;
- (void)setLockOverrideEnabled:(BOOL)enabled forReason:(id)reason;
- (void)enableLockOverrideForReason:(id)reason suggestOrientation:(UIInterfaceOrientation)orientation;
- (void)enableLockOverrideForReason:(id)reason forceOrientation:(UIInterfaceOrientation)orientation;
- (BOOL)lockOverrideEnabled;
- (void)updateLockOverrideForCurrentDeviceOrientation;
- (void)_updateLockStateWithChanges:(id)changes;
- (void)_updateLockStateWithOrientation:(int)orientation changes:(id)changes;
- (void)_updateLockStateWithOrientation:(int)orientation forceUpdateHID:(BOOL)forceHID changes:(id)changes;
- (BOOL)_effectivelyLocked;
@end

@interface UIImage()
+ (UIImage *)_applicationIconImageForBundleIdentifier:(NSString *)identifier format:(int)format scale:(int)scale;
+ (UIImage *)_applicationIconImageForBundleIdentifier:(NSString *)identifier roleIdentifier:(id)roleIdentifier format:(int)format scale:(int)scale;
@end