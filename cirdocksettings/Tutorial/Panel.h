//
//  Panel.h
//  CirDock
//
//  Created by Maro Development on 6/20/15.
//
//

#import <UIKit/UIKit.h>
#import "TutViewController.h"
#import "../iCarousel.h"

enum HoldSection {
    HoldDefault = 0,
    HoldBanners,
    HoldFavorites,
    SectionsCount
};

@interface Panel : UIViewController
@property (nonatomic) NSInteger index;
@property (strong, nonatomic) IBOutlet UIView *titleView;
@property (strong, nonatomic) IBOutlet UIView *descriptionView;
@property (strong, nonatomic) TutViewController *parentController;

- (void)displayPanel;
@end
