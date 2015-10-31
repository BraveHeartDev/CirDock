//
//  CirDockTapTutViewController.h
//  CirDock
//
//  Created by Maro Development on 6/20/15.
//
//

#import "Panel.h"

@interface CirDockTapTutViewController : Panel <iCarouselDataSource, iCarouselDelegate>
@property (strong, nonatomic) IBOutlet iCarousel *carousel;
@property (strong, nonatomic) IBOutlet UILabel *holdStatusLabel;
@property (nonatomic) BOOL pressed;
@end
