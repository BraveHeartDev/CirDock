//
//  TutViewController.h
//  CirDock
//
//  Created by Maro Development on 6/20/15.
//
//

#import <UIKit/UIKit.h>

@interface TutViewController : UIPageViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource>
@property (nonatomic, retain) NSArray *panels;

- (void)exitTutorial;
@end

