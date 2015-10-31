//        `.-::::::::::::::::::::::::::-.`
//      ./++++++++++++++++++++++++++++++++/.
//     -+++++++++++/:-..````..-:/+++++++++++-
//    .+++++++++/-` .-://////:-. `-/+++++++++`
//    -+++++++:` ./+:-`      `.://. -++++++++-
//    -++++++. .o/.  .-:////:-.  `/++++++++++-
//    -+++oo` /o. `:++++++++++++:/+++++++++++-
//    -ooss. /o` .+++++++++++++++++++++++++++-
//    -sss/ .s. `+ooooooooooooooooooooooooooo-
//    -sss- :o  :oooooooooooooooooooooooooooo-
//    -sss- :o  :oooooooooooooooooooooooooooo-
//    -sss/ .s. `oooooooooooooooooooooooooooo-
//    -ssss` /+` .+oooooooooooooooooooooooooo-
//    -sssso` /+. `:oooooooooooo:/ooooooooooo-
//    -sssooo. .+:`  .://++//:.  .++ooooooooo-
//    -ssooooo/` .:/:.`      `.:+/. -oooooooo-
//    .ooooooooo/-` `.-::::::--. `-/ooooooooo.
//     :ooooooo++++/:-.``````.--/ooooooooooo:
//      ./oooo+++++++/////////+ooooooooooo+.
//        `-::::::::::::::::://////////:-`
//                   Cirdock
//    Developed by Amro Thabet aka Brave Heart

#import "./iCarousel.h"
#import "defines.h"
#import <objc/runtime.h>
#import <substrate.h>
#import "UIAlertView+Blocks.h"

#define PLISTPATH @"/var/mobile/Library/Preferences/com.braveheart.cirdock.plist"

//This file is used to check if this is the first time the tweak runs after it's installed to give the user the opportunity to save his/her current dock layout (as a pic)
#define FIRSTRUNPATH @"/var/mobile/Library/CirDockFirstRun"

#import <libkern/OSAtomic.h>
#import <notify.h>

//An array used to store the bundleIDs of all the running apps for glowing/highlighting purposes.
static NSMutableArray *runningApplications;

//Darwin Notification Callbacks. Names explain them ;)
void ColorChangedCallback(CFNotificationCenterRef center,void *observer,CFStringRef name,const void *object,CFDictionaryRef userInfo);
void CarouselTypeChangedCallback(CFNotificationCenterRef center, void *observer,CFStringRef name, const void *object, CFDictionaryRef userInfo);
void AppChangedCallback(CFNotificationCenterRef center,void *observer,CFStringRef name,const void *object,CFDictionaryRef userInfo);
void BadgeChangedCallback(CFNotificationCenterRef center,void *observer,CFStringRef name,const void *object,CFDictionaryRef userInfo);

#pragma mark IconFinder

@interface SBIconView ()
- (void)setLabelHidden:(BOOL)hidden;
@end

@interface IconFinder : NSObject
{
@public
    OSSpinLock spinLock;
}

+ (IconFinder *)sharedInstance;
- (void)didReceiveMemoryWarning;
- (SBIconView *)getIconViewWithID:(NSString *)bundleID badged:(BOOL)badged labelVisible:(BOOL)labelVisible;
- (UIImage *)getImageWithID:(NSString *)displayIdentifier andSize:(int)iconSize;

@property (nonatomic, retain) SBIconModel *model;
@property (nonatomic, retain) NSMutableDictionary *appsDict;
@property (nonatomic, retain) SBApplicationController *appController;
@end

@implementation IconFinder
@synthesize model, appsDict, appController;

+ (IconFinder*)sharedInstance
{
    static dispatch_once_t p = 0;
    
    __strong static IconFinder *_sharedObject = nil;
    
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (void)didReceiveMemoryWarning
{
    OSSpinLockLock(&spinLock);
    [appsDict removeAllObjects];
    OSSpinLockUnlock(&spinLock);
}

- (id)init
{
    self = [super init];
    if (self)
    {
        // IconFinder initialization!
        appsDict = [[NSMutableDictionary alloc]init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (UIImage *)getImageWithID:(NSString *)displayIdentifier andSize:(int)iconSize
{
    UIImage *image;
    NSString *displayName;
    
    
    OSSpinLockLock(&spinLock);
    NSArray *appData = [appsDict valueForKey:displayIdentifier];
    OSSpinLockUnlock(&spinLock);
    
    NSString *iconSizeKey = [NSString stringWithFormat:@"%i", (iconSize == 0)?0:1];
    
    NSMutableDictionary *imageDict;
    if(appData != nil)
        imageDict = appData[0];
    
    if(appData == nil || imageDict == nil || imageDict[iconSizeKey] == nil)
    {
        // Cached Image not found. Getting sbapplicationcontroller instance
        if(appController == nil)
        {
            Class SBApplicationControllerClass = objc_getClass("SBApplicationController");
            appController = (SBApplicationController*)[SBApplicationControllerClass sharedInstanceIfExists];
        }
        
        // Getting application display name
        SBApplication *app;
        if(appController)
        {
            app = ([appController respondsToSelector:@selector(applicationWithDisplayIdentifier:)])?[appController applicationWithDisplayIdentifier:displayIdentifier]:[appController applicationWithBundleIdentifier:displayIdentifier];
            if(app == nil)
                return nil;
            
            displayName = [app displayName];
        }
        
        // Getting correctly sized image
        SBIcon *icon;
        SBIconModel *iconModel = (SBIconModel *)([objc_getClass("SBIconViewMap") instancesRespondToSelector:@selector(iconModel)] ? [((SBIconViewMap *)[objc_getClass("SBIconViewMap") homescreenMap]) iconModel] : [objc_getClass("SBIconModel") sharedInstance]);
        if ([iconModel respondsToSelector:@selector(applicationIconForDisplayIdentifier:)])
            icon = [iconModel applicationIconForDisplayIdentifier:displayIdentifier];
        else if ([iconModel respondsToSelector:@selector(applicationIconForBundleIdentifier:)])
            icon = [iconModel applicationIconForBundleIdentifier:displayIdentifier];
        else if ([iconModel respondsToSelector:@selector(iconForDisplayIdentifier:)])
            icon = [iconModel iconForDisplayIdentifier:displayIdentifier];
        else
            return nil;
        
        BOOL getIconImage = [icon respondsToSelector:@selector(getIconImage:)];
        
        if (iconSize == 0) {
            image = getIconImage ? [icon getIconImage:0] : [icon smallIcon];
            if (image)
                goto finish;
            if ([app respondsToSelector:@selector(pathForSmallIcon)]) {
                image = [UIImage imageWithContentsOfFile:[app pathForSmallIcon]];
                if (image)
                    goto finish;
            }
        }
        image = getIconImage ? [icon getIconImage:(kCFCoreFoundationVersionNumber >= 675.0) ? 2 : 1] : [icon icon];
        if (image)
            goto finish;
        if ([app respondsToSelector:@selector(pathForIcon)])
            image = [UIImage imageWithContentsOfFile:[app pathForIcon]];
        if (!image)
        {
            // No image found whatsoever!
            return nil;
        }
    }
    else
    {
        // Cached image found!
        return appData[0][iconSizeKey];
    }
    
finish:
    // Retrieving new image
    if(imageDict == nil)
        imageDict = [[NSMutableDictionary alloc]init];
    
    if(image == nil)
        if(displayName == nil)
            displayName = displayIdentifier;
    
    [imageDict setValue:(image == nil)?[NSNull null]:image forKey:iconSizeKey];
    
    OSSpinLockLock(&spinLock);
    [appsDict setValue:@[imageDict, displayName] forKey:displayIdentifier];
    OSSpinLockUnlock(&spinLock);
    
    // New image with ID returned and cached
    return image;
}

- (SBIconView *)getIconViewWithID:(NSString *)identifier badged:(BOOL)badged labelVisible:(BOOL)labelVisible
{
    if(model == nil)
    {
        SBIconController *controller = (SBIconController *)[objc_getClass("SBIconController") sharedInstance];
        model = [controller model];
    }
    
    if(model != nil)
    {
        // Getting SBIcon
        SBIcon *sbIcon = (SBIcon*)[model expectedIconForDisplayIdentifier:identifier];
        if(sbIcon == nil)
        {
            if ([model respondsToSelector:@selector(applicationIconForDisplayIdentifier:)])
                sbIcon = [model applicationIconForDisplayIdentifier:identifier];
            else if ([model respondsToSelector:@selector(applicationIconForBundleIdentifier:)])
                sbIcon = [model applicationIconForBundleIdentifier:identifier];
            else if ([model respondsToSelector:@selector(iconForDisplayIdentifier:)])
                sbIcon = (SBIcon *)[model iconForDisplayIdentifier:identifier];
            else
                return nil;
        }
        
        if(sbIcon == nil)
            return nil;
        
        // Getting SBIconView
        SBIconView *iconView;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0"))
            iconView = [((SBIconView *)[objc_getClass("SBIconView") alloc]) initWithContentType:0];
        else
            iconView = [((SBIconView *)[objc_getClass("SBIconView") alloc]) initWithDefaultSize];
        [iconView setIcon:(SBApplicationIcon *)sbIcon];
        
        // Setting IconView Label state
        
        UIView *labelView = MSHookIvar<UIView*>(iconView, "_labelView");
        if(labelView)
        {
            if(labelVisible == NO)
            {
                [labelView removeFromSuperview];
            }
        }
        else
        {
            [iconView setLabelHidden:!labelVisible];
        }
        
        // Setting IconView Badge state
        id badgeView;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
            badgeView = MSHookIvar<id>(iconView, "_accessoryView");
        else
            badgeView = MSHookIvar<id>(iconView, "_badgeView");
        
        if (badgeView)
        {
            if(badged == NO)
            {
                [badgeView removeFromSuperview];
            }
            //[badgeView setHidden:!badged];
        }
        
        // Returning Icon View
        return iconView;
    }
    else
    {
        // SBIconModel still nil. Unable to return anything.
        return nil;
    }
}

@end

#pragma mark Carousel

@interface Carousel : iCarousel
@property (nonatomic) BOOL isRotated; // Is Horizontal (lanscape?)?
@end
@implementation Carousel
@synthesize isRotated;
@end

#pragma mark CirDock

SBDockView *dock;
SBRootFolderView *rootFolderView;
SBIconModel *dockModel;

enum HoldSection {
    HoldDefault = 0,
    HoldBanners,
    HoldFavorites,
    HoldBannersAndDefault,
    HoldRunningApps,
    SectionsCount
};

enum Animations {
    NoAnim = 0,
    Bounce,
    Flip,
    Pulsate,
    Rotate,
    Wiggle
};

@interface CirDock : NSObject<iCarouselDataSource, iCarouselDelegate>
{
@public
    NSNumber *currentLongHold;
    int anim;
}

@property (nonatomic, retain) Carousel *carousel;
@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) NSMutableArray *origItems;
@property (nonatomic, retain) SBIconModel *iconModel;
@property (nonatomic) CGRect frame;
@property (nonatomic, retain) SpringBoard *springBoard;
@property (nonatomic) UIDeviceOrientation currentOrientation;
@property (nonatomic, retain) NSNumber *currentLongHold;
@property (nonatomic, retain) UILabel *holdStatusLabel;

//Dock Data
//@property (nonatomic) float dockHeightH, dockHeightV;
@property (nonatomic) float dockRadiusH, dockRadiusV;
@property (nonatomic) float iconScaleH, iconScaleV;
@property (nonatomic) float iconSpacingH, iconSpacingV;
@property (nonatomic) float tiltH, tiltV;
@property (nonatomic) int maxVisibleCountH, maxVisibleCountV;
@property (nonatomic) BOOL countDependant, showBackface, wraps, bouncing;
@property (nonatomic) float decelerationRate, perspective, scrollSpeed;

+ (CirDock*)sharedInstance;
- (void)setupView;
- (void)updateFrame:(BOOL)isPortrait;
- (void)switchCarouselType:(iCarouselType)type;
- (void)orientationChanged:(UIDeviceOrientation)orientation;
- (void)addCarouselToDock;
- (void)reloadItemsWithHoldSection:(NSNumber *)section;
- (void)timerFired;
- (void)initCarousel;
- (void)updateActionLabelHidden;
- (void)updateDock;
- (void)updateDockData;
@end

@implementation CirDock
@synthesize carousel, items, origItems, frame, springBoard, currentOrientation, currentLongHold, holdStatusLabel, iconModel;
@synthesize dockRadiusH, dockRadiusV, iconScaleH, iconScaleV, iconSpacingH, iconSpacingV, maxVisibleCountH, maxVisibleCountV, countDependant, showBackface, wraps, tiltH, tiltV;
@synthesize decelerationRate, perspective, scrollSpeed, bouncing;

- (void)updateDockData
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PLISTPATH];
    if(dict)
    {
        id plistValue = dict[@"dockRadius-landscape"];
        dockRadiusH = (plistValue)?[plistValue floatValue]:5.f;
        
        plistValue = dict[@"dockRadius-portrait"];
        dockRadiusV = (plistValue)?[plistValue floatValue]:5.f;
        
        plistValue = dict[@"iconScale-landscape"];
        iconScaleH = (plistValue)?[plistValue floatValue]:1.f;
        
        plistValue = dict[@"iconScale-portrait"];
        iconScaleV = (plistValue)?[plistValue floatValue]:1.f;
        
        plistValue = dict[@"iconSpacing-landscape"];
        iconSpacingH = (plistValue)?[plistValue floatValue]:1.4f;
        
        plistValue = dict[@"iconSpacing-portrait"];
        iconSpacingV = (plistValue)?[plistValue floatValue]:1.2f;
        
        plistValue = dict[@"maxVisIcons-landscape"];
        maxVisibleCountH = (plistValue)?[plistValue intValue]:8;
        
        plistValue = dict[@"maxVisIcons-portrait"];
        maxVisibleCountV = (plistValue)?[plistValue intValue]:8;
        
        plistValue = dict[@"scrollAnimation"];
        anim = (plistValue)?[plistValue intValue]:0;
        
        plistValue = dict[@"countDependant"];
        countDependant = (plistValue)?[plistValue boolValue]:YES;
        
        plistValue = dict[@"showBackface"];
        showBackface = (plistValue)?[plistValue boolValue]:NO;
        
        plistValue = dict[@"wraps"];
        wraps = (plistValue)?[plistValue boolValue]:YES;
        
        plistValue = dict[@"tilt-landscape"];
        tiltH = (plistValue)?[plistValue floatValue]:0.9f;
        
        plistValue = dict[@"tilt-portrait"];
        tiltV = (plistValue)?[plistValue floatValue]:0.9f;
        
        plistValue = dict[@"decelerationRate"];
        decelerationRate = (plistValue)?[plistValue floatValue]:0.85f;
        
        plistValue = dict[@"perspective"];
        perspective = (plistValue)?-([plistValue floatValue]):-0.002f;
        
        plistValue = dict[@"scrollSpeed"];
        scrollSpeed = (plistValue)?[plistValue floatValue]:1.0f;
        
        plistValue = dict[@"bouncing"];
        bouncing = (plistValue)?[plistValue boolValue]:NO;
    }
    else
    {
        dockRadiusH = 96.f;
        dockRadiusV = 96.f;
        iconScaleH = 1.f;
        iconScaleV = 1.f;
        iconSpacingH = 1.4f;
        iconSpacingV = 1.2f;
        maxVisibleCountH = 8;
        maxVisibleCountV = 8;
        anim = 0;
        countDependant = YES;
        showBackface = NO;
        wraps = YES;
        tiltH = 0.9f;
        tiltV = 0.9f;
        decelerationRate = 0.85f;
        perspective = -0.002f;
        scrollSpeed = 1.0f;
        bouncing = NO;
    }
    
    if(carousel)
    {
        carousel.decelerationRate = decelerationRate;
        [carousel setPerspective:perspective];
        carousel.scrollSpeed = scrollSpeed;
        carousel.bounces = bouncing;
    }
}

- (void)timerFired
{
    // Timer Fired!
    
    // Checking if orientation changed.
    if(dock && carousel && springBoard)
    {
        [self orientationChanged:[springBoard activeInterfaceOrientation]];
    }
}

-(void)dealloc
{
    //Extra Grabage Cleaning
    CFNotificationCenterRef centre = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterRemoveObserver( centre, NULL, (__bridge CFStringRef)@"CirDockCarouselChangeNotification", NULL );
    CFNotificationCenterRemoveObserver( centre, NULL, (__bridge CFStringRef)@"CirDockLabelChangeNotification", NULL );
    CFNotificationCenterRemoveObserver( centre, NULL, (__bridge CFStringRef)@"CirDockAppsChangedNotification", NULL );
    CFNotificationCenterRemoveObserver( centre, NULL, (__bridge CFStringRef)@"CirDockBadgeChangeNotification", NULL );
    CFNotificationCenterRemoveObserver( centre, NULL, (__bridge CFStringRef)@"CirDockColorChangeNotification", NULL );
    CFNotificationCenterRemoveObserver( centre, NULL, (__bridge CFStringRef)@"CirDockDockChangedNotification", NULL );
}

+ (CirDock*)sharedInstance
{
    static dispatch_once_t p = 0;
    
    __strong static CirDock *_sharedObject = nil;
    
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (void)addCarouselToDock
{
    if(carousel && dock)
    {
        // Adding Carousel to the dock
        dock.clipsToBounds = YES;
        [dock addSubview:carousel];
        [dock addSubview:holdStatusLabel];
        
        [self updateActionLabelHidden];
        // Carousel added
    }
}

- (void)orientationChanged:(UIDeviceOrientation)orientation
{
//    UIInterfaceOrientation orientation = [springBoard activeInterfaceOrientation];
    //Ignoring specific orientations
    BOOL isPortrait = UIDeviceOrientationIsPortrait(orientation);
    
    if (currentOrientation == orientation && !isPortrait)
    {
        return;
    }
    // Changing orientation
    currentOrientation = orientation;
    
    if(carousel && dock)
        [self updateFrame:isPortrait];
}

- (CirDock*)init
{
    self = [super init];
    if(self)
    {
        // Initialize CirDock Based on Plist
        items = [[NSMutableArray alloc]init];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PLISTPATH];
        if(dict)
        {
            items = [[dict objectForKey:@"enabledApps"] mutableCopy];
        }
        origItems = items;
        anim = NoAnim;
        
        [self initCarousel];
        // Cirdock init end
    }
    return self;
}

- (void)initCarousel
{
    if(self)
    {
        // Initialize carousel
        frame = CGRectMake(0,0,0,0);
        holdStatusLabel = [[UILabel alloc] initWithFrame:frame];
        holdStatusLabel.text = @"D";
        holdStatusLabel.adjustsFontSizeToFitWidth = YES;
        holdStatusLabel.backgroundColor = [UIColor blackColor];
        holdStatusLabel.textColor = [UIColor whiteColor];
        holdStatusLabel.textAlignment = NSTextAlignmentCenter;
        
        carousel = [[Carousel alloc]initWithFrame:frame];
        [self updateDockData];
        carousel.type = iCarouselTypeCylinder;
        carousel.delegate = self;
        carousel.dataSource = self;
        carousel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        carousel.clipsToBounds = YES;
        
        // Select correct carousel type
        // Initialize carousel end
    }
}

- (void)updateFrame:(BOOL)isPortrait
{
    // Updating frame
    self.frame = dock.bounds;
    if(isPortrait)
    {
        carousel.isRotated = NO;
        carousel.vertical = NO;
    }
    else
    {
        carousel.isRotated = YES;
        
        BOOL isVertical = NO;
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PLISTPATH];
        if(dict)
        {
            id plistValue = dict[@"vertLandscape"];
            if(plistValue)
                isVertical = [plistValue boolValue];
        }
        
        carousel.vertical = isVertical;
    }
    carousel.frame = self.frame;
    holdStatusLabel.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 25, 25);
    
    [self reloadItemsWithHoldSection:currentLongHold];
}

- (void)setupView
{
    if(self && dock)
    {
        // Setting Up Carousel Frame
        self.frame = CGRectMake(0,0,0,0);
        
        carousel.frame = self.frame;
        [self addCarouselToDock];
        
        carousel.frame = carousel.superview.bounds;
        self.frame = carousel.frame;
        holdStatusLabel.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 25, 25);
    }
}

- (void)updateActionLabelHidden
{
    BOOL actionLabelHidden = NO;
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PLISTPATH];
    if(dict)
    {
        id plistValue = [dict objectForKey:@"removeActionLabel"];
        
        if (plistValue)
        {
            actionLabelHidden = [plistValue boolValue];
        }
    }
    
    holdStatusLabel.hidden = actionLabelHidden;
}

- (void)switchCarouselType:(iCarouselType)type
{
    if(type != carousel.type)
    {
        // Carousel type changed
        carousel.type = type;
    }
}

#pragma mark iCarousel methods

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carouselInput
{
    if(anim == NoAnim)
        return;
    
    UIView *itemView = carouselInput.currentItemView;
    float animDuration = 0.3f;
    if(anim == Pulsate)
    {
        [UIView animateWithDuration:animDuration/2 animations: ^()
         {
             itemView.alpha = 0.2f;
         } completion:^(BOOL finished)
         {
             [UIView animateWithDuration:animDuration/2 animations: ^()
              {
                  itemView.alpha = 1.0f;
              } completion:nil];
         }];
        return;
    }
    
    BOOL isMovingToRight = ([carouselInput offsetForItemAtIndex:carouselInput.previousItemIndex] < [carouselInput offsetForItemAtIndex:carouselInput.currentItemIndex]);
    NSString *animatedKeyPath;
    switch (anim) {
        case Bounce:
        {
            animDuration = 0.1f;
            if(!carouselInput.isVertical)
            {
                animatedKeyPath = @"position.y";
            }
            else
            {
                animatedKeyPath = @"position.x";
            }
            break;
        }
        case Flip:
        {
            if(!carouselInput.isVertical)
            {
                animatedKeyPath = @"transform.rotation.y";
            }
            else
            {
                animatedKeyPath = @"transform.rotation.x";
            }
            break;
        }
        case Rotate:
        {
            animatedKeyPath = @"transform.rotation.z";
            break;
        }
        case Wiggle:
        {
            animatedKeyPath = @"transform.rotation.z";
            break;
        }
        default:
            break;
    }
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = animatedKeyPath;
    
    switch (anim) {
        case Bounce:
        {
            animation.values = @[ @0, @10, @0, @-10, @0 ];
            animation.keyTimes = @[ @0, @(1 / 4), @(1 / 2), @(3 / 4), @1 ];
            break;
        }
        case Flip:
        {
            animation.values = @[ @0, @(M_PI), @(2 * M_PI) ];
            animation.keyTimes = @[ @0, @0.5, @1 ];
            
            if(isMovingToRight)
                animation.values = @[ @0, @(M_PI), @(2 * M_PI) ];
            
            break;
        }
        case Rotate:
        {
            if(carouselInput.isVertical)
                animation.values = @[@(0), @(360 * M_PI/180)];
            else
            {
                if(isMovingToRight)
                    animation.values = @[@(0), @(360 * M_PI/180)];
                else
                    animation.values = @[@(0), @(-360 * M_PI/180)];
            }
            
            animation.keyTimes = @[ @0, @1 ];
            break;
        }
        case Wiggle:
        {
            animation.values = @[@(0),
                                 @(-30 * M_PI/180),
                                 @(0),
                                 @(30 * M_PI/180),
                                 @(0)];
            animation.keyTimes = @[ @0, @(1 / 4), @(1 / 2), @(3 / 4), @1 ];
            break;
        }
        default:
            break;
    }
    
    
    animation.duration = animDuration;
    animation.additive = YES;
    [itemView.layer addAnimation:animation forKey:@"CirDockAnimation"];
}

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [items count];
}

- (UIView *)carousel:(iCarousel *)carouselInput viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)resView
{
    // Getting the icon of each item
    Class SBApplicationControllerClass = objc_getClass("SBApplicationController");
    if([SBApplicationControllerClass sharedInstanceIfExists])
    {
        NSMutableDictionary *dict = [[NSDictionary dictionaryWithContentsOfFile:PLISTPATH] mutableCopy];
        BOOL isOutOfRange = (index > [items count]);
        IconFinder *finder = [IconFinder sharedInstance];
        SBIconView *iconView;
        
        BOOL isLabelVisible = true;
        BOOL isBadgeVisible = true;
        if(dict)
        {
            isLabelVisible = ![[dict valueForKey:@"removeLabels"] boolValue];
            isBadgeVisible = ![[dict valueForKey:@"removeBadges"] boolValue];
        }
        if(!isOutOfRange)
        {
            iconView = [finder getIconViewWithID:items[index] badged:isBadgeVisible labelVisible:isLabelVisible];
            iconView.userInteractionEnabled = NO;
        }
        
        if(iconView == nil || isOutOfRange)
        {
            // Icon not found so present error icon
            
            if(resView == nil)
            {
                resView = [[UIView alloc]initWithFrame:CGRectMake(0,0,60,74)];
                
                UIImage *errorImage = [finder getImageWithID:@"com.apple.Diagnostics" andSize:1];
                UIImageView *errorView = [[UIImageView alloc] initWithImage:errorImage];
                errorView.contentMode = UIViewContentModeScaleAspectFit;
                errorView.frame = CGRectMake(0,0,62,62);
                errorView.userInteractionEnabled = NO;
                [resView addSubview:errorView];
                
                [resView sizeToFit];
            }
            
            return resView;
        }
        
        // Should Icon Glow?
        BOOL isGlowBGOn = false;
        if(dict)
            isGlowBGOn = [[dict valueForKey:@"isGlowBGOn"] boolValue];
        
        if(isGlowBGOn)
        {
            // Icons should glow, go ahead and edit them
            if([runningApplications filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF IN %@", @[items[index]] ]].count > 0)
            {
                //Application is running
                UIColor *finalColor = [UIColor blackColor];
                NSString *color = [dict valueForKey:@"GlowColor"];
                NSArray *colorValues = [[color lowercaseString] componentsSeparatedByString:@":"];
                if([colorValues count] == 6)
                {
                    CGFloat red = [[colorValues objectAtIndex:1]floatValue];
                    CGFloat green = [[colorValues objectAtIndex:2]floatValue];
                    CGFloat blue = [[colorValues objectAtIndex:3]floatValue];
                    CGFloat alpha = [[colorValues objectAtIndex:4]floatValue];
                    
                    finalColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
                }
                
                UIView *labelView = MSHookIvar<UIView*>(iconView, "_labelView");
                if(isLabelVisible && labelView)
                {
                    labelView.backgroundColor =  finalColor;
                }
                else
                {
                    iconView.layer.shadowColor = finalColor.CGColor;
                    iconView.layer.shadowOpacity = 1;
                    iconView.layer.shadowRadius = 5;
                    iconView.layer.shadowOffset = CGSizeMake(0,0);
                    //iconView.layer.borderColor = finalColor.CGColor;
                    //iconView.layer.borderWidth = 1;
                }
            }
        }
        
        // Resize Icon To fit correctly
        iconView.frame.size = CGSizeMake(iconView.frame.size.width, iconView.frame.size.height*1.08108108f);
        
        if(!isLabelVisible)
        {
            SBIconImageView *imgView = [iconView _iconImageView];
            if(imgView)
                iconView.frame = CGRectMake(iconView.frame.origin.x, iconView.frame.origin.y, imgView.frame.size.width, imgView.frame.size.height);
        }

        float scale = carousel.isRotated?iconScaleH:iconScaleV;
        CATransform3D transform = CATransform3DScale(iconView.layer.sublayerTransform, scale, scale, 1.0f);
        iconView.layer.sublayerTransform = transform;
        
        // Resized Icon
        return iconView;
    }
    else
        return nil;
}

- (CGFloat)carousel:(iCarousel *)carouselInput valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionSpacing:
        {
            return self.carousel.isRotated?iconSpacingH:iconSpacingV;
        }
        case iCarouselOptionRadius:
        {
            return countDependant?value:(self.carousel.isRotated?dockRadiusH:dockRadiusV);
        }
        case iCarouselOptionShowBackfaces:
        {
            return showBackface;
        }
        case iCarouselOptionArc:
        {
            return M_PI * 2;
        }
        case iCarouselOptionWrap:
        {
            return wraps;
        }
        case iCarouselOptionVisibleItems:
        {
            return self.carousel.isRotated?maxVisibleCountH:maxVisibleCountV;//value * 1.5;
        }
        case iCarouselOptionTilt:
        {
            return (self.carousel.type == iCarouselTypeCoverFlow || self.carousel.type == iCarouselTypeCoverFlow2)?(self.carousel.isRotated?tiltH:tiltV):value;
        }
        default:
        {
            return value;
        }
    }
}

- (void)carousel:(iCarousel *)carouselInput didSelectItemAtIndex:(NSInteger)index
{
    if([[carouselInput itemViewAtIndex:index] isKindOfClass:[objc_getClass("SBIconView") class]])
    {
        SBIconView *iconView = (SBIconView*)[carouselInput itemViewAtIndex:index];
        SBApplicationIcon *appIcon = iconView.icon;
        
        [(SBIconController*)[objc_getClass("SBIconController") sharedInstance]_launchIcon:appIcon];
        //[(SBUIController*)[objc_getClass("SBUIController") sharedInstance]launchIcon:appIcon fromLocation:0];
        
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PLISTPATH];
        if(dict)
        {
            id returnToIcon = dict[@"returnToIcon"];
            if(returnToIcon)
            {
                if(![returnToIcon isEqualToString:@""])
                {
                    NSInteger itemViewIndex = [items indexOfObject:returnToIcon];
                    if(itemViewIndex != NSNotFound && itemViewIndex < items.count && itemViewIndex >= 0)
                        [carousel scrollToItemAtIndex:itemViewIndex animated:NO];
                }
            }
        }
        
        /*
         int location = (kCFCoreFoundationVersionNumber >= 847.20)?2:1; //IOS > 7 or not?
         SBApplication *application = [appIcon application];
         [application icon:appIcon launchFromLocation:location];
         */
    }
}

- (void)carousel:(iCarousel *)inputCarousel didHoldItemAtIndex:(NSInteger)index
{
    //if(index == NSNotFound)
    
    // Animate the dock to move out and into the screen
    int tempNewHold = 0;
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PLISTPATH];
    if(dict)
    {
        NSArray *longHold = [dict objectForKey:@"enabledLongHold"];
        int count = 0;
        BOOL found = NO;
        for (NSNumber *i in longHold)
        {
            if([i intValue] == [currentLongHold intValue])
            {
                tempNewHold = (count+1 < longHold.count)?[longHold[count+1] intValue]:0;
                found = YES;
                break;
            }
            count++;
        }
        if(!found)
            tempNewHold = HoldDefault;
    }
    else
    {
        tempNewHold = HoldDefault;
    }
    
    if(tempNewHold != [currentLongHold intValue])
    {
        CGRect initialFrame = inputCarousel.frame;
        [UIView animateWithDuration:0.1 animations: ^()
         {
             inputCarousel.frame = CGRectMake(initialFrame.origin.x, initialFrame.origin.y + initialFrame.size.height, initialFrame.size.width, initialFrame.size.height);
         } completion:^(BOOL finished)
         {
             //CALL ANY FUNCTIONS BEFORE VIEW SHOWN
             [self reloadItemsWithHoldSection:@(tempNewHold)];
             
             inputCarousel.frame = CGRectMake(initialFrame.origin.x, initialFrame.origin.y - initialFrame.size.height, initialFrame.size.width, initialFrame.size.height);
             
             [UIView animateWithDuration:0.1 animations: ^()
              {
                  inputCarousel.frame = initialFrame;
              } completion:^(BOOL finished)
              {
                  //FINISHED ALL ANIMATIONS
              }];
         }];
    }
}

- (void)reloadItemsWithHoldSection:(NSNumber *)tempSection
{
    int section = [tempSection intValue];
    if(section >= SectionsCount)
        section = HoldDefault;
    
    BOOL similarSection = (section==[currentLongHold intValue]);
    
    if(!similarSection)
    {
        
        switch (section) {
            case HoldDefault:
            {
                holdStatusLabel.text = @"D";
                self.items = origItems;
                break;
            }
            case HoldBanners:
            {
                Class SBApplicationControllerClass = objc_getClass("SBApplicationController");
                Class SBApplicationIconClass = objc_getClass("SBApplicationIcon");
                
                SBApplicationController *controller = (SBApplicationController*)[SBApplicationControllerClass sharedInstanceIfExists];
                
                NSMutableArray *bannerItems = [[NSMutableArray alloc] init];
                
                NSMutableArray *allApps;
                NSMutableDictionary *dict = [[NSDictionary dictionaryWithContentsOfFile:PLISTPATH] mutableCopy];
                if(dict)
                {
                    if([[dict valueForKey:@"badgeAllApps"] boolValue])
                        allApps = [[controller allApplications] mutableCopy];
                }
                
                if(allApps == nil)
                {
                    allApps = [[NSMutableArray alloc] init];
                    for(NSString *identifier in origItems)
                    {
                        SBApplication *app = (controller == nil)?nil:(([controller respondsToSelector:@selector(applicationWithDisplayIdentifier:)])?[controller applicationWithDisplayIdentifier:identifier]:[controller applicationWithBundleIdentifier:identifier]);
                        if(app)
                            [allApps addObject:app];
                    }
                }
                
                
                for(SBApplication *app in allApps)
                {
                    if(app)
                    {
                        if([((SBApplicationIcon*)[[SBApplicationIconClass alloc]initWithApplication:app]) badgeValue] > 0)
                            [bannerItems addObject:([app respondsToSelector:@selector(displayIdentifier)]?[app displayIdentifier]:[app bundleIdentifier])];
                    }
                }
                
                holdStatusLabel.text = @"B";
                self.items = bannerItems;
                break;
            }
            case HoldBannersAndDefault:
            {
                Class SBApplicationControllerClass = objc_getClass("SBApplicationController");
                Class SBApplicationIconClass = objc_getClass("SBApplicationIcon");
                
                SBApplicationController *controller = (SBApplicationController*)[SBApplicationControllerClass sharedInstanceIfExists];
                
                NSMutableArray *bannerItems = [[NSMutableArray alloc] init];
                
                NSMutableArray *allApps;
                NSMutableDictionary *dict = [[NSDictionary dictionaryWithContentsOfFile:PLISTPATH] mutableCopy];
                if(dict)
                {
                    if([[dict valueForKey:@"badgeAllApps"] boolValue])
                        allApps = [[controller allApplications] mutableCopy];
                }
                
                if(allApps == nil)
                {
                    allApps = [[NSMutableArray alloc] init];
                    for(NSString *identifier in origItems)
                    {
                        SBApplication *app = (controller == nil)?nil:(([controller respondsToSelector:@selector(applicationWithDisplayIdentifier:)])?[controller applicationWithDisplayIdentifier:identifier]:[controller applicationWithBundleIdentifier:identifier]);
                        if(app)
                            [allApps addObject:app];
                    }
                }
                
                
                for(SBApplication *app in allApps)
                {
                    if(app)
                    {
                        if([((SBApplicationIcon*)[[SBApplicationIconClass alloc]initWithApplication:app]) badgeValue] > 0)
                            [bannerItems addObject:([app respondsToSelector:@selector(displayIdentifier)]?[app displayIdentifier]:[app bundleIdentifier])];
                    }
                }
                
                for (NSString *displayIdentifier in origItems)
                {
                    if(![bannerItems containsObject:displayIdentifier])
                        [bannerItems addObject:displayIdentifier];
                }
                
                holdStatusLabel.text = @"BD";
                self.items = bannerItems;
                break;
            }
            case HoldRunningApps:
            {
                holdStatusLabel.text = @"R";
                self.items = runningApplications;
                break;
            }
            case HoldFavorites:
            {
                NSMutableArray *favItems = [@[] mutableCopy];
                NSMutableDictionary *dict = [[NSDictionary dictionaryWithContentsOfFile:PLISTPATH] mutableCopy];
                if(dict)
                {
                    favItems = [[dict objectForKey:@"favApps"] mutableCopy];
                }
                holdStatusLabel.text = @"F";
                self.items = favItems;
                break;
            }
            default:
                break;
        }
        [self.carousel scrollToItemAtIndex:0 animated:NO];
        currentLongHold = @(section);
    }
    [self.carousel reloadData];
}

- (void)updateDock
{
    [self updateDockData];
    
    //if(rootFolderView)
    //    [rootFolderView _layoutSubviews];
    
    [self reloadItemsWithHoldSection:currentLongHold];
}

@end

%group CirDockGroup

%hook SBRootFolderController
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // Handle orientation change
    %orig;
    [[CirDock sharedInstance] orientationChanged:fromInterfaceOrientation];
}
%end


%hook SBRootFolderView
-(void)_layoutSubviews
{
    %orig;
    
    // Layout the dock to display it
    if(dock)
    {
        CirDock *cirDock = [CirDock sharedInstance];
        //cirDock.dock = dock;
        [cirDock setupView];
    }
}
%end

%hook SBApplication
- (void)setBadge:(id)badge
{
    // Add applications or remove applications from the badges section
    
    %orig;
    int retVal = [badge intValue];
    
    CirDock *cirDock = [CirDock sharedInstance];
    
    if(retVal <= 0 && ([cirDock.currentLongHold intValue] == HoldBanners || [cirDock.currentLongHold intValue] == HoldBannersAndDefault))
    {
        [cirDock.items removeObject:([self respondsToSelector:@selector(displayIdentifier)]?[self displayIdentifier]:[self bundleIdentifier])];
        [cirDock.carousel reloadData];
    }
    else if(retVal > 0 && ([cirDock.currentLongHold intValue] == HoldBanners || [cirDock.currentLongHold intValue] == HoldBannersAndDefault))
    {
        //To remove duplicates
        [cirDock.items removeObject:([self respondsToSelector:@selector(displayIdentifier)]?[self displayIdentifier]:[self bundleIdentifier])];
        [cirDock.items insertObject:([self respondsToSelector:@selector(displayIdentifier)]?[self displayIdentifier]:[self bundleIdentifier]) atIndex:0];
        [cirDock.carousel reloadData];
    }
}
%end

%hook SBApplicationController

-(void)uninstallApplication:(SBApplication*)application
{
    // Add or remove applications from the enabled apps
    
    NSMutableDictionary *dict = [[NSDictionary dictionaryWithContentsOfFile:PLISTPATH] mutableCopy];
    if(dict)
    {
        NSMutableArray *items = [[dict objectForKey:@"enabledApps"]mutableCopy];
        [items removeObject:([application respondsToSelector:@selector(displayIdentifier)]?[application displayIdentifier]:[application bundleIdentifier])];
        
        [dict setObject:items forKey:@"enabledApps"];
        [dict writeToFile:PLISTPATH atomically:YES];
        
        CFNotificationCenterRef centre = CFNotificationCenterGetDarwinNotifyCenter();
        CFNotificationCenterPostNotification( centre, (__bridge CFStringRef)@"CirDockAppsChangedNotification", NULL, NULL, YES );
    }
    
    %orig;
}

%end
%end

%group preInitFuncs
%hook SBDockIconListView
- (NSUInteger)iconsInRowForSpacingCalculation
{
    // Set # of dock icons to 0
    return 0;
}
+ (NSUInteger)iconColumnsOrRows
{
    // Set # of dock r&c to 0
    return 0;
}
+ (NSUInteger)iconRowsForInterfaceOrientation:(NSInteger)orientation
{
    // Set # of dock rows to 0
    return 0;
}
%end

%hook SBDockView

- (SBDockView*)initWithDockListView:(SBDockIconListView*)listView forSnapshot:(BOOL)snapshot
{
    %orig;
    if(self)
    {
        // Remove Normal Dock from view
        [listView removeFromSuperview];
        dockModel = [listView model];
    }
    return self;
}

%end

%hook SBRootFolderView
-(void)_layoutSubviews
{
    %orig;
    
    dock = MSHookIvar<SBDockView*>(self, "_dockView");
}

- (id)init
{
    %orig;
    rootFolderView = self;
    return self;
}
%end

%hook SBWorkspace

-(void)applicationProcessDidExit:(FBProcess *)applicationProcess withContext:(id)context {
    if (runningApplications == nil) {
        runningApplications = [[NSMutableArray alloc] init];
        
        %orig;
        return;
    }
    if ([runningApplications containsObject:applicationProcess.applicationInfo.bundleIdentifier]) {
        [runningApplications removeObject:applicationProcess.applicationInfo.bundleIdentifier];
    }
    
    Class SBApplicationControllerClass = objc_getClass("SBApplicationController");
    if([SBApplicationControllerClass sharedInstanceIfExists])
    {
        CirDock *cirDock = [CirDock sharedInstance];
        [cirDock performSelectorOnMainThread:@selector(reloadItemsWithHoldSection:) withObject:cirDock.currentLongHold waitUntilDone:YES];
    }
    %orig;
}

-(void)applicationProcessDidLaunch:(FBProcess *)applicationProcess {
    if (runningApplications == nil) {
        runningApplications = [[NSMutableArray alloc] init];
    }
    [runningApplications addObject:applicationProcess.applicationInfo.bundleIdentifier];
    
    Class SBApplicationControllerClass = objc_getClass("SBApplicationController");
    if([SBApplicationControllerClass sharedInstanceIfExists])
    {
        CirDock *cirDock = [CirDock sharedInstance];
        [cirDock performSelectorOnMainThread:@selector(reloadItemsWithHoldSection:) withObject:cirDock.currentLongHold waitUntilDone:YES];
    }
    %orig;
}

%end
%end

#pragma mark Notifications

void BadgeChangedCallback(CFNotificationCenterRef center,void *observer,CFStringRef name,const void *object,CFDictionaryRef userInfo)
{
    // Badge Changed Notification
    CirDock *cirDock = [CirDock sharedInstance];
    if(name == (__bridge CFStringRef)@"CirDockBadgeChangeNotification" && cirDock.carousel)
    {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PLISTPATH];
        if(dict)
        {
            if([cirDock.currentLongHold intValue] == HoldBanners || [cirDock.currentLongHold intValue] == HoldBannersAndDefault)
                [cirDock reloadItemsWithHoldSection:cirDock.currentLongHold];
        }
    }
}

void AppChangedCallback(CFNotificationCenterRef center,void *observer,CFStringRef name,const void *object,CFDictionaryRef userInfo)
{
    // App Changed Notification
    CirDock *cirDock = [CirDock sharedInstance];
    if(name == (__bridge CFStringRef)@"CirDockAppsChangedNotification" && cirDock.carousel)
    {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PLISTPATH];
        if(dict)
        {
            cirDock.items = [dict objectForKey:@"enabledApps"];
            
            cirDock.origItems = cirDock.items;
            
            //cirDock.currentLongHold = @(HoldDefault);
            [cirDock reloadItemsWithHoldSection:cirDock.currentLongHold];
        }
    }
}

void LabelChangeNotificationTweak(CFNotificationCenterRef center, void *observer,CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    // Carousel Type Changed Notification
    CirDock *cirDock = [CirDock sharedInstance];
    if(name == (__bridge CFStringRef)@"CirDockLabelChangeNotification")
    {
        [cirDock updateActionLabelHidden];
    }
}

void CarouselTypeChangedCallback(CFNotificationCenterRef center, void *observer,CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    // Carousel Type Changed Notification
    CirDock *cirDock = [CirDock sharedInstance];
    if(name == (__bridge CFStringRef)@"CirDockCarouselChangeNotification" && cirDock.carousel)
    {
        id plistValue;
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PLISTPATH];
        if(dict)
        {
            plistValue = [dict objectForKey:@"kListValue"];
            
            if (plistValue)
            {
                [cirDock switchCarouselType:(iCarouselType)[plistValue intValue]];
            }
        }
    }
}

void ColorChangedCallback(CFNotificationCenterRef center,void *observer,CFStringRef name,const void *object,CFDictionaryRef userInfo)
{
    // Highlight Color Changed Notification
    if(name == (__bridge CFStringRef)@"CirDockColorChangeNotification")
    {
        CirDock *cirDock = [CirDock sharedInstance];
        BOOL isGlowBGOn = false;
        NSMutableDictionary *dict = [[NSDictionary dictionaryWithContentsOfFile:PLISTPATH] mutableCopy];
        if(dict)
            isGlowBGOn = [[dict valueForKey:@"isGlowBGOn"] boolValue];
        
        if(cirDock.springBoard && isGlowBGOn)
        {
            [cirDock reloadItemsWithHoldSection:cirDock.currentLongHold];
        }
    }
}

void DockChangedNotificationTweak(CFNotificationCenterRef center,void *observer,CFStringRef name,const void *object,CFDictionaryRef userInfo)
{
    // Highlight Color Changed Notification
    if(name == (__bridge CFStringRef)@"CirDockDockChangedNotification")
    {
        CirDock *cirDock = [CirDock sharedInstance];
        [cirDock updateDock];
    }
}

#pragma mark Cirdock Late Init Code

void runCirDock(CFNotificationCenterRef center,void *observer,CFStringRef name,const void *object,CFDictionaryRef userInfo)
{
    if(name == (__bridge CFStringRef)UIApplicationDidFinishLaunchingNotification)
    {
        // Running CirDock
        CirDock *cirDock = [CirDock sharedInstance];
        // CirDock sharedInstance Created!
        
        NSMutableDictionary *dict = [[NSDictionary dictionaryWithContentsOfFile:PLISTPATH] mutableCopy];
        if(!dict)
        {
            // Dictionary not found
            dict = [[NSMutableDictionary alloc]init];
            
            // Getting Device Type
            if ([[UIDevice currentDevice].model isEqualToString:@"iPod touch"]) //iPod
            {
                // iPod
                [dict setObject:@[@"com.apple.MobileSMS", @"com.apple.mobilemail", @"com.apple.mobilesafari", @"com.apple.Music"] forKey:@"enabledApps"];
            }
            else if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) //iPhone
            {
                // iPhone
                [dict setObject:@[@"com.apple.mobilephone", @"com.apple.mobilemail", @"com.apple.mobilesafari", @"com.apple.Music"] forKey:@"enabledApps"];
            }
            else //iPad
            {
                // iPad
                [dict setObject:@[@"com.apple.mobilesafari", @"com.apple.mobilemail", @"com.apple.videos", @"com.apple.Music"] forKey:@"enabledApps"];
            }
            // Obtained Device Type
            
            [dict setObject:@"3" forKey:@"kListValue"];
            [dict writeToFile:PLISTPATH atomically:YES];
            // Wrote Defaults to Plist
        }
        
        BOOL foundSwitchType = false;
        if(dict)
        {
            id plistValue = [dict objectForKey:@"kListValue"];
            
            if (plistValue)
            {
                [cirDock switchCarouselType:(iCarouselType)[plistValue intValue]];
                foundSwitchType = true;
            }
        }
        
        if(!foundSwitchType)
            [cirDock switchCarouselType:(iCarouselType)3];
        
        if(![[NSFileManager defaultManager]fileExistsAtPath:FIRSTRUNPATH])
        {
            // First Time Running CirDock
            if([[NSFileManager defaultManager]createFileAtPath:FIRSTRUNPATH contents:nil attributes:nil])
            {
                // Initializing First Time Running Group\nDisplay warning message
                [UIAlertView showWithTitle:@"Warning" message:@"The installation of CirDock moves all the applications on the dock to the homescreen. So please take a screenshot of how your dock currently looks like and then respring for the tweak to commence." cancelButtonTitle:@"Dismiss" otherButtonTitles:nil tapBlock:nil];
                [IconFinder sharedInstance];
            }
            else
            {
                // CirDockError: creating file!\n
            }
        }
        else
        {
            cirDock.springBoard = (SpringBoard*)[UIApplication sharedApplication]; //self;
            [IconFinder sharedInstance];
            // Not First Time Running CirDock... Initializing Group!
            
            %init(CirDockGroup);
            [cirDock setupView];
        }
        
        // Adding Notification Observers
        CFNotificationCenterRef centre = CFNotificationCenterGetDarwinNotifyCenter();
        CFNotificationCenterAddObserver ( centre, NULL, CarouselTypeChangedCallback, (__bridge CFStringRef)@"CirDockCarouselChangeNotification", NULL, NO );
        CFNotificationCenterAddObserver ( centre, NULL, LabelChangeNotificationTweak, (__bridge CFStringRef)@"CirDockLabelChangeNotification", NULL, NO );
        CFNotificationCenterAddObserver ( centre, NULL, AppChangedCallback, (__bridge CFStringRef)@"CirDockAppsChangedNotification", NULL, NO );
        CFNotificationCenterAddObserver ( centre, NULL, BadgeChangedCallback, (__bridge CFStringRef)@"CirDockBadgeChangeNotification", NULL, NO );
        CFNotificationCenterAddObserver ( centre, NULL, ColorChangedCallback, (__bridge CFStringRef)@"CirDockColorChangeNotification", NULL, NO );
        CFNotificationCenterAddObserver ( centre, NULL, DockChangedNotificationTweak, (__bridge CFStringRef)@"CirDockDockChangedNotification", NULL, NO );
        
        // Setting Up Timer
        [NSTimer scheduledTimerWithTimeInterval:2 target:cirDock selector:@selector(timerFired) userInfo:nil repeats:YES];
    }
}

@interface ISIconSupport : NSObject {
    NSMutableSet *extensions;
}

+ (id)sharedInstance;
- (NSString *)extensionString;
- (BOOL)addExtension:(NSString *)extension;
- (BOOL)isBeingUsedByExtensions;
- (void)repairAndReloadIconState;
- (void)repairAndReloadIconState:(NSDictionary *)iconState;
@end

%ctor
{
    
    dlopen("/Library/MobileSubstrate/DynamicLibraries/IconSupport.dylib", RTLD_NOW);
    [[objc_getClass("ISIconSupport") sharedInstance] addExtension:@"CirDock"];
    
    // Initialize CirDock.
    runningApplications = [[NSMutableArray alloc]init];
    
    if([[NSFileManager defaultManager]fileExistsAtPath:FIRSTRUNPATH]) // && passed)
    {
        %init(preInitFuncs);
    }
    //Add ApplicationDidFinishLaunching observer (required for ios 8.3+ since code cant be run until after springboard fully launches)
    CFNotificationCenterAddObserver ( CFNotificationCenterGetLocalCenter(), NULL, runCirDock, (__bridge CFStringRef)UIApplicationDidFinishLaunchingNotification, NULL, NO );
}
