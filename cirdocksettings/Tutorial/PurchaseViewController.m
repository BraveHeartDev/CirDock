//
//  PurchaseViewController.m
//  CirDock
//
//  Created by Maro Development on 6/20/15.
//
//

#import "PurchaseViewController.h"

@interface PurchaseViewController ()

@end

@implementation PurchaseViewController
@synthesize cirDockImageView, isFirstImage;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    isFirstImage = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)exitPressed:(id)sender
{
    [self.parentController exitTutorial];
}

- (IBAction)handleTap:(UITapGestureRecognizer*)recognizer
{
    CGPoint touchPoint = [recognizer locationInView:recognizer.view.superview];
    UIView *imageView = recognizer.view;
    CGRect imageRect = CGRectMake(imageView.center.x - (imageView.frame.size.height/2), imageView.center.y - (imageView.frame.size.height/2), imageView.frame.size.height, imageView.frame.size.height);
    if(CGRectContainsPoint(imageRect, touchPoint))
    {
        if(isFirstImage)
        {
            NSData *imgData = [[NSData alloc] initWithContentsOfFile:@"/Library/PreferenceBundles/CirDockSettings.bundle/Credits-WB.png"];
            UIImage *img = [[UIImage alloc] initWithData:imgData];
            [UIView transitionWithView:cirDockImageView
                              duration:0.3
                               options:UIViewAnimationOptionTransitionFlipFromRight
                            animations:^{
                                //  Set the new image
                                //  Since its done in animation block, the change will be animated
                                cirDockImageView.image = img;
                            } completion:^(BOOL finished) {
                                //  Do whatever when the animation is finished
                            }];
        }
        else
        {
            NSData *imgData = [[NSData alloc] initWithContentsOfFile:@"/Library/PreferenceBundles/CirDockSettings.bundle/Icon-WB.png"];
            UIImage *img = [[UIImage alloc] initWithData:imgData];
            [UIView transitionWithView:cirDockImageView
                              duration:0.3
                               options:UIViewAnimationOptionTransitionFlipFromLeft
                            animations:^{
                                //  Set the new image
                                //  Since its done in animation block, the change will be animated
                                cirDockImageView.image = img;
                            } completion:^(BOOL finished) {
                                //  Do whatever when the animation is finished
                            }];
        }
        isFirstImage = !isFirstImage;
    }
}

- (void)displayPanel
{
    self.titleView.alpha = 0;
    self.descriptionView.alpha = 0;
    self.exitBtn.alpha = 0;
    
    self.titleView.frame = CGRectOffset(self.titleView.frame, 30, 0);
    
    [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
        self.titleView.alpha = 1;
        self.titleView.frame = CGRectOffset(self.titleView.frame, -30, 0);
    } completion:^(BOOL finished) {
        
        self.descriptionView.frame = CGRectOffset(self.descriptionView.frame, -30, 0);
        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
            self.descriptionView.alpha = 1;
            self.descriptionView.frame = CGRectOffset(self.descriptionView.frame, 30, 0);
            self.exitBtn.alpha = 1;
        } completion:nil];
        
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
