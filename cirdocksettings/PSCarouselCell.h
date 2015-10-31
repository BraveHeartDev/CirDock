#import <Preferences/Preferences.h>
#import "iCarousel.h"

enum Animations {
    NoAnim = 0,
    Bounce,
    Flip,
    //HeartBeat,
    //Pulsate,
    Rotate,
    Wiggle
};

@interface PSCarouselCell : PSTableCell<iCarouselDataSource, iCarouselDelegate>
{
	iCarousel *carousel;
    int anim;
}

@property (nonatomic, retain) iCarousel *carousel;
@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) NSMutableDictionary *cachedData;

@property (nonatomic) float dockRadiusV;
@property (nonatomic) float iconScaleV;
@property (nonatomic) float iconSpacingV;
@property (nonatomic) float tiltV;
@property (nonatomic) int maxVisibleCountV;
@property (nonatomic) BOOL countDependant, showBackface, wraps, bouncing;
@property (nonatomic) float decelerationRate, perspective, scrollSpeed;

- (void)switchCarouselType:(iCarouselType)type;
@end