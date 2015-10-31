#import "PSStepperCell.h"

@implementation PSStepperCell
@synthesize stepper, label;

/*
-(void)dealloc
{
	[stepper release], stepper = nil;
	[label release], label = nil;

	[super dealloc];
}
*/

-(id)initWithStyle:(int)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)spec {

	//call the super class's method to create the switch cell
	self = [super initWithStyle:style reuseIdentifier:identifier specifier:spec]; 

	if (self)
	{
		CGRect frame = self.frame;
		stepper = [[UIStepper alloc] initWithFrame:CGRectMake(frame.size.width - ((frame.size.height - stepperSpaceFromSides)*3) - (stepperSpaceFromSides), stepperSpaceFromSides/2, (frame.size.height - stepperSpaceFromSides)*3, frame.size.height - stepperSpaceFromSides)];
		[stepper addTarget:self action:@selector(stepperPressed:) forControlEvents:UIControlEventValueChanged];

		CGRect labelFrame = CGRectMake((frame.size.width - ((frame.size.height - stepperSpaceFromSides)*6) - (stepperSpaceFromSides))+ 5, 0, (frame.size.height - stepperSpaceFromSides2)*2, self.frame.size.height);
		label = [[UILabel alloc]initWithFrame:labelFrame];
		label.numberOfLines = 1;
		label.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
		label.adjustsFontSizeToFitWidth = YES;
		label.adjustsLetterSpacingToFitWidth = YES;
		label.minimumScaleFactor = 10.0f/12.0f;
		label.clipsToBounds = YES;
		label.backgroundColor = [UIColor clearColor];
		label.textColor = [UIColor blackColor];
		label.textAlignment = NSTextAlignmentRight;
		[self addSubview:label];
		[self bringSubviewToFront:label];

		stepper.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin);
		label.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin);

		[self addSubview:stepper];
		[self bringSubviewToFront:stepper];
	}

	return self;

}

//-(void)setSpecifier:(PSSpecifier*)specifier
-(void)layoutSubviews
{
	[super layoutSubviews];
	PSSpecifier *specifier = _specifier;
	NSString *classTypeString = [specifier propertyForKey:@"cellClass"];
	if(classTypeString != nil)
	{
		//[super setSpecifier:specifier];
		NSString *color = [specifier propertyForKey:@"colour"];
		if([[color lowercaseString] isEqualToString:@""])
			color = [specifier propertyForKey:@"color"];

		UIColor *finalColor = nil;
		if([[color lowercaseString] isEqualToString:@"black"])
		{
			finalColor = [UIColor blackColor];
		}
		else if([[color lowercaseString] isEqualToString:@"white"])
		{
			finalColor = [UIColor whiteColor];
		}
		else if([[color lowercaseString] isEqualToString:@"grey"])
		{
			finalColor = [UIColor grayColor];
		}
		else if([[color lowercaseString] isEqualToString:@"gray"])
		{
			finalColor = [UIColor grayColor];
		}
		else if([[color lowercaseString] isEqualToString:@"red"])
		{
			finalColor = [UIColor redColor];
		}
		else if([[color lowercaseString] isEqualToString:@"green"])
		{
			finalColor = [UIColor greenColor];
		}
		else if([[color lowercaseString] isEqualToString:@"blue"])
		{
			finalColor = [UIColor blueColor];
		}
		else if([[color lowercaseString] isEqualToString:@"cyan"])
		{
			finalColor = [UIColor cyanColor];
		}
		else if([[color lowercaseString] isEqualToString:@"yellow"])
		{
			finalColor = [UIColor yellowColor];
		}
		else if([[color lowercaseString] isEqualToString:@"magenta"])
		{
			finalColor = [UIColor magentaColor];
		}
		else if([[color lowercaseString] isEqualToString:@"orange"])
		{
			finalColor = [UIColor orangeColor];
		}
		else if([[color lowercaseString] isEqualToString:@"purple"])
		{
			finalColor = [UIColor purpleColor];
		}
		else if([[color lowercaseString] isEqualToString:@"brown"])
		{
			finalColor = [UIColor brownColor];
		}
		else if([[color lowercaseString] rangeOfString:@"rgba:"].location != NSNotFound)
		{
			NSArray *values = [[color lowercaseString] componentsSeparatedByString:@":"];
			if([values count] == 6)
			{
				CGFloat red = [[values objectAtIndex:1]floatValue];
				CGFloat green = [[values objectAtIndex:2]floatValue];
				CGFloat blue = [[values objectAtIndex:3]floatValue];
				CGFloat alpha = [[values objectAtIndex:4]floatValue];
				BOOL isNotNormalized = [[values objectAtIndex:5]boolValue];
				if(isNotNormalized)
				{
					red = red / 255.f;
					green = green / 255.f;
					blue = blue / 255.f;
					alpha = alpha / 255.f;
				}

				finalColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
			}
			else
				finalColor = [UIColor blackColor];
		}
		else if([[color lowercaseString] rangeOfString:@"hsba:"].location != NSNotFound)
		{
			NSArray *values = [[color lowercaseString] componentsSeparatedByString:@":"];
			if([values count] == 6)
			{
				CGFloat hue = [[values objectAtIndex:1]floatValue];
				CGFloat saturation = [[values objectAtIndex:2]floatValue];
				CGFloat brightness = [[values objectAtIndex:3]floatValue];
				CGFloat alpha = [[values objectAtIndex:4]floatValue];
				BOOL isNotNormalized = [[values objectAtIndex:5]boolValue];
				if(isNotNormalized)
				{
					hue = hue / 255.f;
					saturation = saturation / 255.f;
					brightness = brightness / 255.f;
					alpha = alpha / 255.f;
				}

				finalColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
			}
			else
				finalColor = [UIColor blackColor];
		}
		else
		{
			//Default
			finalColor = [UIColor blackColor];
		}

		stepper.tintColor = finalColor;
		label.textColor = finalColor;
		//[finalColor release];

		id continuous = [specifier propertyForKey:@"continuous"];
		if(continuous)
			stepper.continuous = [continuous boolValue];

		id autorepeat = [specifier propertyForKey:@"autorepeat"];
		if(autorepeat)
			stepper.autorepeat = [autorepeat boolValue];

		id wraps = [specifier propertyForKey:@"wraps"];
		if(wraps)
			stepper.wraps = [wraps boolValue];

		id minimumValue = [specifier propertyForKey:@"minimumValue"];
		if(minimumValue)
			stepper.minimumValue = [minimumValue doubleValue];

		id maximumValue = [specifier propertyForKey:@"maximumValue"];
		if(maximumValue)
			stepper.maximumValue = [maximumValue doubleValue];

		id stepValue = [specifier propertyForKey:@"stepValue"];
		if(stepValue)
			stepper.stepValue = [stepValue doubleValue];
        
        NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist",[specifier propertyForKey:@"defaults"]];
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:path];
        if(specifier->getter == nil)
        {
            if(dictionary)
            {
                id keyValue = [dictionary valueForKey:[specifier propertyForKey:@"key"]];
                if(keyValue)
                    stepper.value = [keyValue doubleValue];
                else
                {
                    id value = [specifier propertyForKey:@"default"];
                    
                    if(value)
                    {
                        [dictionary setValue:value forKey:[specifier propertyForKey:@"key"]];
                        [dictionary writeToFile:path atomically:YES];
                        stepper.value = [value doubleValue];
                    }
                    else
                    {
                        [dictionary setValue:[NSNumber numberWithInt:stepper.minimumValue] forKey:[specifier propertyForKey:@"key"]];
                        [dictionary writeToFile:path atomically:YES];
                        stepper.value = stepper.minimumValue;
                    }
                }
            }
            else
            {
                id value = [specifier propertyForKey:@"default"];
                
                if(value)
                {
                    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:value forKey:[specifier propertyForKey:@"key"]];
                    [dictionary writeToFile:path atomically:YES];
                    stepper.value = [value doubleValue];
                }
                else
                {
                    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:stepper.minimumValue] forKey:[specifier propertyForKey:@"key"]];
                    [dictionary writeToFile:path atomically:YES];
                    stepper.value = stepper.minimumValue;
                }
            }
        }
        else
        {
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[specifier->target class] instanceMethodSignatureForSelector:specifier->getter]];
            [invocation setSelector:specifier->getter];
            [invocation setTarget:specifier->target];
            [invocation invoke];
            
            __unsafe_unretained id retValue;
            [invocation getReturnValue:&retValue];
            
            if(retValue)
            {
                stepper.value = [retValue doubleValue];
            }
            else
            {
                id value = [specifier propertyForKey:@"default"];
                if(value)
                {
                    stepper.value = [value doubleValue];
                }
                else
                {
                    stepper.value = stepper.minimumValue;
                }
            }
        }
        label.text = [NSString stringWithFormat:@"%i", (int)stepper.value];
	}
}

-(void)stepperPressed:(id)sender
{
    if(_specifier->setter == nil)
    {
        NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist",[_specifier propertyForKey:@"defaults"]];
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:path];
        if(!dictionary)
            dictionary = [[NSMutableDictionary alloc] init];
        
        [dictionary setValue:[NSNumber numberWithDouble:stepper.value] forKey:[_specifier propertyForKey:@"key"]];
        [dictionary writeToFile:path atomically:YES];
    }
    else
    {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[_specifier->target class] instanceMethodSignatureForSelector:_specifier->setter]];
        [invocation setSelector:_specifier->setter];
        [invocation setTarget:_specifier->target];
        NSNumber *value = [NSNumber numberWithDouble:stepper.value];
        [invocation setArgument:&value atIndex:2];
        [invocation setArgument:&_specifier atIndex:3];
        [invocation invoke];
    }

	label.text = [NSString stringWithFormat:@"%i", (int)stepper.value];
}

@end