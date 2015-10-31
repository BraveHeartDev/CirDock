#import "PSColorPicker.h"
#import "GlobalDefines.h"
#import <objc/runtime.h>

@interface UITableView()
@property (nonatomic) UIView *wrapperView;
@end

@implementation PSColorPicker
@synthesize colorPicker, defaultsName, keyName, defaultColor;

-(void)viewWillAppear:(BOOL)appear
{
	[super viewWillAppear:appear];
	if(self.specifier != nil)
	{
		UIView *tableViewWrapper = nil;
		for(UIView *tempView in ((UITableView*)self.table).subviews)
		{
		    if([tempView isKindOfClass:[objc_getClass("UITableViewWrapperView") class]])
		    {
			tableViewWrapper = tempView;
			break;
		    }
		}
		if(tableViewWrapper == nil)
		    return;

		defaultsName = [self.specifier propertyForKey:@"defaults"];
		keyName = [self.specifier propertyForKey:@"key"];

		//[defaultsName retain];
		//[keyName retain];

		defaultColor = nil;
		NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", defaultsName];
		NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
		if(dictionary)
		{
			NSString *color = [dictionary valueForKey:keyName];
			NSArray *colorValues = [[color lowercaseString] componentsSeparatedByString:@":"];
			if([colorValues count] == 6)
			{
				CGFloat red = [[colorValues objectAtIndex:1]floatValue];
				CGFloat green = [[colorValues objectAtIndex:2]floatValue];
				CGFloat blue = [[colorValues objectAtIndex:3]floatValue];
				CGFloat alpha = [[colorValues objectAtIndex:4]floatValue];
				BOOL isNotNormalized = [[colorValues objectAtIndex:5]boolValue];
				if(isNotNormalized)
				{
					red = red / 255.f;
					green = green / 255.f;
					blue = blue / 255.f;
					alpha = alpha / 255.f;
				}
				defaultColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
			}
			else
			{
				defaultColor = [UIColor blackColor];
			}
		}
		else
		{
			defaultColor = [UIColor blackColor];
		}

		CGRect pickerRect;
		CGFloat width = 250.f/375.f * tableViewWrapper.bounds.size.width;
		CGFloat height = 340.f/603.f * tableViewWrapper.bounds.size.height;
		pickerRect = CGRectMake(tableViewWrapper.bounds.size.width/2 - width/2, tableViewWrapper.bounds.size.height/2 - height/2-20, width, height);

		if(colorPicker)
		{
		    [colorPicker removeFromSuperview];
		    colorPicker = nil;
		}
		colorPicker = [[HRColorPickerView alloc] initWithFrame:pickerRect];
		colorPicker.color = defaultColor;
		colorPicker.brightnessSlider.brightnessLowerLimit = @0;
		[colorPicker addTarget:self action:@selector(colorDidChanged:) forControlEvents:UIControlEventValueChanged];

		[tableViewWrapper addSubview:colorPicker];
	}
	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:1 green:80.f/255.f blue:70.f/255.f alpha:1];;
	[[UIApplication sharedApplication] keyWindow].tintColor = [UIColor colorWithRed:1 green:80.f/255.f blue:70.f/255.f alpha:1];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[[UIApplication sharedApplication] keyWindow].tintColor = nil;
	self.view.tintColor = nil;
	self.navigationController.navigationBar.tintColor = nil;
}


- (id)specifiers {
	if(_specifiers == nil)
	{
		_specifiers = [[NSArray alloc]init];
	}
	return _specifiers;
}

- (void)colorDidChanged:(HRColorPickerView *)pickerView
{
	UIColor *color = pickerView.color;

	//Your code handling a color change in the picker view.
	NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", defaultsName];
	NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
	if(!dictionary)
	{
		dictionary = [[NSDictionary alloc] init];
	}
	CGFloat red, green, blue, alpha;
	[color getRed:&red green:&green blue:&blue alpha:&alpha];
	[dictionary setValue:[NSString stringWithFormat:@"rgba:%f:%f:%f:%f:0", red, green, blue, alpha] forKey:keyName];
	[dictionary writeToFile:path atomically:YES];

	CFNotificationCenterRef centre = CFNotificationCenterGetDarwinNotifyCenter();
	CFNotificationCenterPostNotification( centre, (__bridge CFStringRef)@"CirDockColorChangeNotification", NULL, NULL, YES );
}
@end