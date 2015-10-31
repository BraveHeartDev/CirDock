//
//  CirDockHoldTutViewController.h
//  CirDock
//
//  Created by Maro Development on 6/21/15.
//
//

#import "Panel.h"

@interface CirDockHoldTutViewController : Panel <iCarouselDataSource, iCarouselDelegate>
@property (strong, nonatomic) IBOutlet iCarousel *carousel;
@property (strong, nonatomic) IBOutlet UILabel *holdStatusLabel;
@property (nonatomic) enum HoldSection holdSection;
@end
