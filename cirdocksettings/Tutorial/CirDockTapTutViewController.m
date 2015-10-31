//
//  CirDockTapTutViewController.m
//  CirDock
//
//  Created by Maro Development on 6/20/15.
//
//

#import "CirDockTapTutViewController.h"

@interface CirDockTapTutViewController ()

@end

@implementation CirDockTapTutViewController

@synthesize pressed, carousel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    carousel.superview.clipsToBounds = YES;
    
    carousel.type = iCarouselTypeCylinder;
    carousel.delegate = self;
    carousel.dataSource = self;
    carousel.decelerationRate = 0.85;
    carousel.clipsToBounds = YES;
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
    if(!pressed)
    {
        pressed = YES;
        [carousel reloadData];
    }
}

- (void)carousel:(iCarousel *)inputCarousel didHoldItemAtIndex:(NSInteger)index
{
    //
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
    
    if(pressed)
    {
        label.text = @"PRESSED!";
    }
    else
    {
        label.text = @"Item";
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
