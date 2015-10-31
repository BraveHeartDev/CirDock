#import <Preferences/Preferences.h>

#define stepperSpaceFromSides 16
#define stepperSpaceFromSides2 8

@interface PSStepperCell : PSTableCell
{
	UIStepper *stepper;
	UILabel *label;
}

@property (nonatomic, retain) UIStepper *stepper;
@property (nonatomic, retain) UILabel *label;

-(void)stepperPressed:(id)sender;
@end