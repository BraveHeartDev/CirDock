#import "PSCirDockSwitch.h"

@implementation PSCirDockSwitch

-(id)initWithStyle:(int)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)spec {

	//call the super class's method to create the switch cell
	self = [super initWithStyle:style reuseIdentifier:identifier specifier:spec]; 

	if (self)
	{
        if([self.control isKindOfClass:[UISwitch class]])
        {
            ((UISwitch *)self.control).onTintColor = [UIColor colorWithRed:1 green:80.f/255.f blue:70.f/255.f alpha:1];
        }
	}

	return self;

}

@end