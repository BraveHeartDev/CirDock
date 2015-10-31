//
//  CirDockHoldTutViewController.m
//  CirDock
//
//  Created by Maro Development on 6/21/15.
//
//

#import "CirDockHoldTutViewController.h"

@interface CirDockHoldTutViewController ()

@end

@implementation CirDockHoldTutViewController
@synthesize holdSection, carousel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    carousel.superview.clipsToBounds = YES;
    
    carousel.type = iCarouselTypeCylinder;
    carousel.delegate = self;
    carousel.dataSource = self;
    carousel.decelerationRate = 0.85;
    carousel.clipsToBounds = YES;
    
    holdSection = HoldDefault;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark iCarousel Functions
- (void)carousel:(iCarousel *)carouselInput didSelectItemAtIndex:(NSInteger)index
{
    //
}

- (void)carousel:(iCarousel *)inputCarousel didHoldItemAtIndex:(NSInteger)index
{
    [UIView animateWithDuration:0.1 animations: ^()
     {
         inputCarousel.frame = CGRectOffset(inputCarousel.frame, 0, inputCarousel.frame.size.height);
     } completion:^(BOOL finished)
     {
         //CALL ANY FUNCTIONS BEFORE VIEW SHOWN
         if(self.holdSection == HoldDefault)
         {
             self.holdSection = HoldFavorites;
         }
         else if (self.holdSection == HoldFavorites)
         {
             self.holdSection = HoldBanners;
         }
         else if (self.holdSection == HoldBanners)
         {
             self.holdSection = HoldDefault;
         }
         
         switch (self.holdSection)
         {
             case HoldDefault:
             {
                 self.holdStatusLabel.text = @"D";
                 break;
             }
                 
             case HoldFavorites:
             {
                 self.holdStatusLabel.text = @"F";
                 break;
             }
                 
             case HoldBanners:
             {
                 self.holdStatusLabel.text = @"B";
                 break;
             }
                 
             default:
                 break;
         }
         
         inputCarousel.frame = CGRectOffset(inputCarousel.frame, 0, -(2 * inputCarousel.frame.size.height));
         [inputCarousel reloadData];
         
         [UIView animateWithDuration:0.1 animations: ^()
          {
              inputCarousel.frame = CGRectOffset(inputCarousel.frame, 0, inputCarousel.frame.size.height);
          } completion:^(BOOL finished)
          {
              //FINISHED ALL ANIMATIONS
          }];
     }];
}

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return 20;
}

- (UIView *)carousel:(iCarousel *)carouselInput viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UIView *resView = [[UIView alloc]initWithFrame:CGRectMake(0,0,60,74)];
    
    // list all the apps
    NSData *imgData = [[NSData alloc] initWithContentsOfFile:@"/Library/PreferenceBundles/CirDockSettings.bundle/Icon-WB.png"];
     UIImage *icon = [[UIImage alloc] initWithData:imgData];
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:icon];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = CGRectMake(0,0,62,62);
    [resView addSubview:imageView];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(5.5,62.5,resView.bounds.size.width - 5.5, 19)];
    
    switch (self.holdSection)
    {
        case HoldDefault:
        {
            label.text = @"Default";
            break;
        }
            
        case HoldFavorites:
        {
            label.text = @"Favorited";
            break;
        }
            
        case HoldBanners:
        {
            label.text = @"Badged";
            break;
        }
            
        default:
            break;
    }
    
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:11];
    label.textAlignment = NSTextAlignmentCenter;
    [resView addSubview:label];
    
    [resView sizeToFit];
    [label sizeToFit];
    label.center = CGPointMake(resView.bounds.size.width/2, (62.5 + label.bounds.size.height)/2);
    label.frame = CGRectMake(label.frame.origin.x, 62.5, label.frame.size.width, 19);
    return resView;
}

- (CGFloat)carousel:(iCarousel *)carouselInput valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionSpacing:
        {
            return 1.2;
        }
        case iCarouselOptionRadius:
        {
            return value;
        }
        case iCarouselOptionShowBackfaces:
        {
            return NO;
        }
        case iCarouselOptionArc:
        {
            return M_PI;
        }
        case iCarouselOptionVisibleItems:
        {
            return value * 1.5;
        }
        default:
        {
            return value;
        }
    }
}

@end
