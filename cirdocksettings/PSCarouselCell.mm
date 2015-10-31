#import "PSCarouselCell.h"
#define PLISTPATH @"/var/mobile/Library/Preferences/com.braveheart.cirdock.plist"

#import <AppList/AppList.h>

void NotificationCalled(CFNotificationCenterRef center,void *observer,CFStringRef name,const void *object,CFDictionaryRef userInfo);
void AppChangedNotificationCalled(CFNotificationCenterRef center,void *observer,CFStringRef name,const void *object,CFDictionaryRef userInfo);
void DockChangedNotificationCalled(CFNotificationCenterRef center,void *observer,CFStringRef name,const void *object,CFDictionaryRef userInfo);

PSCarouselCell *localCarouselCell = nil;
BOOL isGlowBGOn = false;
BOOL isLabelVisible = true;
UIColor *finalColor = [UIColor blackColor];

@interface CarouselItemView : UIView
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UILabel *label;
@end
@implementation CarouselItemView
@synthesize imageView, label;
@end

@implementation PSCarouselCell
@synthesize carousel, items;
@synthesize dockRadiusV, iconScaleV, iconSpacingV, maxVisibleCountV, countDependant, showBackface, wraps, tiltV, decelerationRate, perspective, scrollSpeed, bouncing, cachedData;

- (void)updateDockData
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PLISTPATH];
    if(dict)
    {
        id plistValue = dict[@"dockRadius-portrait"];
        dockRadiusV = (plistValue)?[plistValue floatValue]:5.f;
        
        plistValue = dict[@"iconScale-portrait"];
        iconScaleV = (plistValue)?[plistValue floatValue]:1.f;
        
        plistValue = dict[@"iconSpacing-portrait"];
        iconSpacingV = (plistValue)?[plistValue floatValue]:1.2f;
        
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
        dockRadiusV = 96.f;
        iconScaleV = 1.f;
        iconSpacingV = 1.2f;
        maxVisibleCountV = 8;
        anim = 0;
        countDependant = YES;
        showBackface = NO;
        wraps = YES;
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

-(void)dealloc
{
    CFNotificationCenterRef centre = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterRemoveObserver( centre, NULL, (__bridge CFStringRef)@"CirDockCarouselChangeNotification", NULL );
    CFNotificationCenterRemoveObserver( centre, NULL, (__bridge CFStringRef)@"CirDockAppsChangedNotification", NULL );
}

-(id)initWithStyle:(int)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)spec {
    
    //call the super class's method to create the switch cell
    self = [super initWithStyle:style reuseIdentifier:identifier specifier:spec];
    
    if (self)
    {
        CGRect frame = self.bounds;
        
        cachedData = [[NSMutableDictionary alloc]init];
        
        items = [[NSMutableArray alloc]init];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PLISTPATH];
        if(dict)
        {
            items = [dict objectForKey:@"enabledApps"];
        }
        
        ALApplicationList *appList = [ALApplicationList sharedApplicationList];
        NSDictionary *identifiers = [appList applicationsFilteredUsingPredicate:nil];
        for (NSString *bundleID in items)
        {
            UIImage *image = [appList iconOfSize:ALApplicationIconSizeLarge forDisplayIdentifier:bundleID];
            NSString *displayName = identifiers[bundleID];
            
            NSArray *cellData = @[(image == nil)?[NSNull null]:image, (displayName == nil)?bundleID:displayName];

            [cachedData setValue:cellData forKey:bundleID];
        }
        
        carousel = [[iCarousel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 96)];
        [self updateDockData];
        carousel.type = iCarouselTypeCylinder;
        carousel.delegate = self;
        carousel.dataSource = self;
        carousel.decelerationRate = 0.85;
        carousel.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth);
        carousel.clipsToBounds = YES;
        
        id plistValue;
        if(dict)
        {
            plistValue = [dict objectForKey:@"kListValue"];
            
            if (plistValue)
            {
                [self switchCarouselType:(iCarouselType)[plistValue intValue]];
            }
        }
        
        [self addSubview:carousel];
        carousel.frame = frame;
        self.backgroundColor = [UIColor whiteColor]; //colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.0];
        
        localCarouselCell = self;
        CFNotificationCenterRef centre = CFNotificationCenterGetDarwinNotifyCenter();
        CFNotificationCenterAddObserver ( centre, NULL, NotificationCalled, (__bridge CFStringRef)@"CirDockCarouselChangeNotification", NULL, NO );
        CFNotificationCenterAddObserver ( centre, NULL, AppChangedNotificationCalled, (__bridge CFStringRef)@"CirDockAppsChangedNotification", NULL, NO );
        CFNotificationCenterAddObserver ( centre, NULL, DockChangedNotificationCalled, (__bridge CFStringRef)@"CirDockDockChangedNotification", NULL, NO );
    }
    
    return self;
    
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    PSSpecifier *specifier = _specifier;
    NSString *classTypeString = [specifier propertyForKey:@"cellClass"];
    if(classTypeString != nil)
    {
        //[super setSpecifier:specifier];
        //NSString *path = [specifier propertyForKey:@"path"];
        //UIImage *image = [UIImage imageWithContentsOfFile:path];
        //cellImageView.image = image;
    }
}

#pragma mark iCarousel methods

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carouselInput
{
    if(anim == NoAnim)
        return;
    
    UIView *itemView = carouselInput.currentItemView;
    float animDuration = 0.3f;
    
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
            break;
        }
            /*case Pulsate:
             {
             animation.values = @[ @1, @0, @1 ];
             animation.keyTimes = @[ @0, @0.5, @1 ];
             break;
             }*/
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

- (UIView *)carousel:(iCarousel *)carouselInput viewForItemAtIndex:(NSInteger)index reusingView:(CarouselItemView *)view
{
    if(view == nil)
    {
        view = [[CarouselItemView alloc]initWithFrame:CGRectMake(0,0,62,62)];
        
        view.imageView = [[UIImageView alloc]initWithImage:nil];
        view.imageView.contentMode = UIViewContentModeScaleAspectFit;
        view.imageView.frame = CGRectMake(0,0,62,62);
        view.imageView.layer.shadowColor = [UIColor blackColor].CGColor;
        view.imageView.layer.shadowOpacity = 0;
        view.imageView.layer.shadowRadius = 3;
        view.imageView.layer.shadowOffset = CGSizeMake(3,0);
        [view addSubview:view.imageView];
        
        view.label = [[UILabel alloc]initWithFrame:CGRectMake(5.5,62.5,view.bounds.size.width - 5.5, 19)];
        view.label.font = [UIFont fontWithName:@"HelveticaNeue" size:11];
        view.label.textAlignment = NSTextAlignmentCenter;
        view.label.backgroundColor = [UIColor clearColor];
        view.label.alpha = 0;
        [view addSubview:view.label];
    }
    
    NSString *bundleIdentifier = items[index];
    NSArray *array = cachedData[bundleIdentifier];
    if(array == nil)
    {
        ALApplicationList *appList = [ALApplicationList sharedApplicationList];
        NSDictionary *identifiers = [appList applicationsFilteredUsingPredicate:nil];
        UIImage *image = [appList iconOfSize:ALApplicationIconSizeLarge forDisplayIdentifier:bundleIdentifier];
        NSString *displayName = identifiers[bundleIdentifier];
        
        NSArray *cellData = @[(image == nil)?[NSNull null]:image, (displayName == nil)?bundleIdentifier:displayName];
        [cachedData setValue:cellData forKey:bundleIdentifier];
    }
    
    if(array != nil)
    {
        // list all the apps
        id icon = array[0];
        view.imageView.image = [icon isKindOfClass:[NSNull class]]?nil:icon;
        
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PLISTPATH];
        if(dict)
        {
            isLabelVisible = ![[dict valueForKey:@"removeLabels"] boolValue];
        }
        else
        {
            isLabelVisible = true;
        }
        
        if(isGlowBGOn)
        {
            
                if(isLabelVisible)
                {
                    view.label.backgroundColor =  finalColor;
                }
                else
                {
                    view.imageView.layer.shadowColor = finalColor.CGColor;
                    view.imageView.layer.shadowOpacity = 1;
                    view.imageView.layer.shadowRadius = 5;
                    view.imageView.layer.shadowOffset = CGSizeMake(0,0);
                }
        }
        
        if(isLabelVisible)
        {
            view.label.text = array[1];
            view.label.alpha = 1;
            [view.label sizeToFit];
            view.label.center = CGPointMake(view.bounds.size.width/2, (62.5 + view.label.bounds.size.height)/2);
            view.label.frame = CGRectMake(view.label.frame.origin.x, 62.5, view.label.frame.size.width, 19);
            
            view.frame = CGRectMake(0, 0, 62, 81.5); //81.5 = 62.5 + 19
        }
        
        CATransform3D transform = CATransform3DScale(CATransform3DIdentity, iconScaleV, iconScaleV, 1.0f);
        view.layer.sublayerTransform = transform;
        
        return view;
    }
    
    return nil;
}

- (CGFloat)carousel:(iCarousel *)carouselInput valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionSpacing:
        {
            return iconSpacingV;
        }
        case iCarouselOptionRadius:
        {
            return countDependant?value:dockRadiusV;
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
            return maxVisibleCountV;//value * 1.5;
        }
        case iCarouselOptionTilt:
        {
            return (self.carousel.type == iCarouselTypeCoverFlow || self.carousel.type == iCarouselTypeCoverFlow2)?tiltV:value;
        }
        default:
        {
            return value;
        }
    }
}

- (void)switchCarouselType:(iCarouselType)type
{
    if(type != carousel.type)
    {
        carousel.type = type;
    }
}

- (void)updateDock
{
    [self updateDockData];
    
    [carousel reloadData];
}

@end

void AppChangedNotificationCalled(CFNotificationCenterRef center,void *observer,CFStringRef name,const void *object,CFDictionaryRef userInfo)
{
    if(name == (__bridge CFStringRef)@"CirDockAppsChangedNotification" && localCarouselCell)
    {
        isGlowBGOn = false;
        finalColor = [UIColor blackColor];
        
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PLISTPATH];
        if(dict)
        {
            isGlowBGOn = [[dict valueForKey:@"isGlowBGOn"] boolValue];
            
            if(isGlowBGOn)
            {
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
            }
            
            localCarouselCell.items = [dict objectForKey:@"enabledApps"];
            [localCarouselCell.carousel reloadData];
        }
    }
}

void NotificationCalled(CFNotificationCenterRef center,
                        void *observer,
                        CFStringRef name,
                        const void *object,
                        CFDictionaryRef userInfo)
{
    if(name == (__bridge CFStringRef)@"CirDockCarouselChangeNotification" && localCarouselCell)
    {
        id plistValue;
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PLISTPATH];
        if(dict)
        {
            plistValue = [dict objectForKey:@"kListValue"];
            
            if (plistValue)
            {
                [localCarouselCell switchCarouselType:(iCarouselType)[plistValue intValue]];
            }
        }
    }
}

void DockChangedNotificationCalled(CFNotificationCenterRef center,void *observer,CFStringRef name,const void *object,CFDictionaryRef userInfo)
{
    if(name == (__bridge CFStringRef)@"CirDockDockChangedNotification" && localCarouselCell)
    {
        [localCarouselCell updateDock];
    }
}