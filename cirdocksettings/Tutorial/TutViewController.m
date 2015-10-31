//
//  TutViewController.m
//  CirDock
//
//  Created by Maro Development on 6/20/15.
//
//

#import "TutViewController.h"
#import "PurchaseViewController.h"
#import "CirDockTapTutViewController.h"
#import "CirDockHoldTutViewController.h"
#import "Panel.h"

#define NibPath @"/Library/PreferenceBundles/CirDockSettings.bundle/"

@interface TutViewController ()
@property (nonatomic, retain) Panel *emptyController;
@end

@implementation TutViewController
@synthesize panels, emptyController;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.dataSource = self;
    self.delegate = self;
    self.view.backgroundColor = [UIColor colorWithRed:1 green:80.f/255.f blue:70.f/255.f alpha:1];
    
    PurchaseViewController *pVC = [[PurchaseViewController alloc]initWithNibName:@"PurchaseViewController" bundle:[NSBundle bundleWithPath:NibPath]];
    pVC.index = 0;
    pVC.parentController = self;
    
    CirDockTapTutViewController *tapVC = [[CirDockTapTutViewController alloc]initWithNibName:@"CirDockTapTutViewController" bundle:[NSBundle bundleWithPath:NibPath]];
    tapVC.index = 1;
    tapVC.parentController = self;
    
    CirDockHoldTutViewController *holdVC = [[CirDockHoldTutViewController alloc]initWithNibName:@"CirDockHoldTutViewController" bundle:[NSBundle bundleWithPath:NibPath]];
    holdVC.index = 2;
    holdVC.parentController = self;
    
    panels = @[pVC, tapVC, holdVC];
    
    [self setViewControllers:@[pVC] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self addChildViewController:tapVC];
    [self addChildViewController:holdVC];
    
    emptyController = [[Panel alloc]init];
    emptyController.view.backgroundColor = [UIColor clearColor];
    emptyController.index = 3;
    [self addChildViewController:emptyController];
    
    [pVC displayPanel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)exitTutorial
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIPageViewControllerDelegate Functions

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    Panel *panel = pendingViewControllers[0];
    if (panel && [panel isKindOfClass:[Panel class]])
    {
        panel.titleView.alpha = 0;
        panel.descriptionView.alpha = 0;
        
        if([panel isKindOfClass:[PurchaseViewController class]])
            ((PurchaseViewController *)panel).exitBtn.alpha = 0;
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed)
    {
        if(self.viewControllers.count > 0)
        {
            if(![self.viewControllers[0] isEqual:previousViewControllers[0]])
            {
                Panel *panel = self.viewControllers[0];
                if([panel isEqual:emptyController])
                    [self exitTutorial];
                else if([panel isKindOfClass:[Panel class]])
                    [panel displayPanel];
            }
        }
    }
}

#pragma mark UIPageViewControllerDataSource Functions

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [((Panel*)viewController) index];
    
    if (index == 0)
    {
        return nil;
    }
    
    index--;
    
    return panels[index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [((Panel*)viewController) index];
    
    index++;
    
    if (index == panels.count)
    {
        return emptyController;
    }
    else if(index > panels.count)
        return nil;
    
    return panels[index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    // The number of items reflected in the page indicator.
    return panels.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    // The selected item reflected in the page indicator.
    return 0;
}

@end
