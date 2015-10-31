//
//  Panel.m
//  CirDock
//
//  Created by Maro Development on 6/20/15.
//
//

#import "Panel.h"

@interface Panel ()

@end

@implementation Panel
@synthesize index, titleView, descriptionView;

- (void)displayPanel
{
    titleView.alpha = 0;
    descriptionView.alpha = 0;
    titleView.frame = CGRectOffset(titleView.frame, 30, 0);
    
    [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
        titleView.alpha = 1;
        titleView.frame = CGRectOffset(titleView.frame, -30, 0);
    } completion:^(BOOL finished) {
        
        descriptionView.frame = CGRectOffset(descriptionView.frame, -30, 0);
        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
            descriptionView.alpha = 1;
            descriptionView.frame = CGRectOffset(descriptionView.frame, 30, 0);
        } completion:nil];
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[self displayPanel];
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

@end
