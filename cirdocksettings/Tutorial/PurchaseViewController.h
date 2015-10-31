//
//  PurchaseViewController.h
//  CirDock
//
//  Created by Maro Development on 6/20/15.
//
//

#import <UIKit/UIKit.h>
#import "Panel.h"

@interface PurchaseViewController : Panel
@property (strong, nonatomic) IBOutlet UIButton *exitBtn;
@property (strong, nonatomic) IBOutlet UIImageView *cirDockImageView;
@property (nonatomic) BOOL isFirstImage;
@end
