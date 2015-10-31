#import <Preferences/Preferences.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>
#import <substrate.h>
#import "UIAlertView+Blocks.h"
#import "Tutorial/TutViewController.h"
#import <AppList/AppList.h>

#define PLPATH @"/var/mobile/Library/Preferences/com.braveheart.cirdock.plist"
#define TwitterMessage @"https://youtu.be/-SJZZEO1O48 Check out CirDock! An amazing new tweak that evolutionizes the device's dock! @Alsafa7Dev"

#define FIRSTRUNPATHSETTINGS @"/var/mobile/Library/CirDockFirstRun"

@interface PSListController()
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion;
- (void)viewDidLayoutSubviews;
@end

@interface CirDockSettingsListController : PSListController <MFMailComposeViewControllerDelegate, UINavigationControllerDelegate>{
}

@property (nonatomic, retain) UIButton *heart;

- (id)readPrefValue:(PSSpecifier*)spec;
- (void)setPrefValue:(id)value specifier:(PSSpecifier*)spec;
- (void)heartPressed;
- (void)requestFeat;
- (void)displayTutorial;
- (void)respring;
@end

@implementation CirDockSettingsListController
@synthesize heart;

- (void)respring
{
    system("killall backboardd");
}

- (void)displayTutorial
{
    TutViewController *tutController = [[TutViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    [self presentViewController:tutController animated:YES completion:nil];
}

- (void)requestFeat
{
    NSString *mailSubject = @"CirDock Feature Request";
    NSString *mailBody = @"Feature Description: ";
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
        
        mailComposeViewController.mailComposeDelegate = self;
        [mailComposeViewController setToRecipients:[NSArray arrayWithObjects:@"alsafa7dev@gmail.com",nil]];
        [mailComposeViewController setSubject:mailSubject];
        [mailComposeViewController setMessageBody:mailBody isHTML:YES];
        mailComposeViewController.delegate = self;
        [self.navigationController presentModalViewController:mailComposeViewController animated:YES];
    }
    else
    {
        // Then escape the prefix using the NSString method
        NSString *mailtoStr = [[NSString stringWithFormat:@"mailto:alsafa7dev@gmail.com?subject=%@&body=%@", mailSubject, mailBody] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        // And let the application open the merged URL
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailtoStr]];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            [UIAlertView showWithTitle:@"Status" message:@"The email has been saved to the drafts." cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
            break;
        case MFMailComposeResultSent:
            [UIAlertView showWithTitle:@"Status" message:@"The email has been sent successfully." cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
            break;
        case MFMailComposeResultFailed:
            [UIAlertView showWithTitle:@"Status" message:@"The email was not able to be sent." cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
            break;
        default:
            [UIAlertView showWithTitle:@"Status" message:@"The email was not sent." cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
            break;
    }
    [controller dismissModalViewControllerAnimated:YES];
}

- (void)heartPressed
{
    heart.enabled = NO;
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [mySLComposerSheet setInitialText:TwitterMessage];
        
        [mySLComposerSheet addURL:[NSURL URLWithString:@"https://youtu.be/5iQvwmQKG1Y"]];
        
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            heart.enabled = YES;
        }];
        
        [((UIViewController*)self) presentViewController:mySLComposerSheet animated:YES completion:nil];
    }
    else
    {
        [UIAlertView showWithTitle:@"Error" message:@"Could not share message. No Twitter account found. Please add a Twitter account to the Twitter section and try again." cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (CirDockSettingsListController*)init
{
    self = [super init];
    if(self)
    {
        NSData *imgData = [[NSData alloc] initWithContentsOfFile:@"/Library/PreferenceBundles/CirDockSettings.bundle/Icon-Small.png"];
        UIImage *img = [[UIImage alloc] initWithData:imgData];
        UIImageView *imgView = [[UIImageView alloc]initWithImage:img];
        imgView.frame = CGRectMake(0, 0, 29, 29);
        ((UINavigationItem*)self.navigationItem).titleView = imgView;
        
        imgData = [[NSData alloc] initWithContentsOfFile:@"/Library/PreferenceBundles/CirDockSettings.bundle/Heart.png"];
        UIImage *image = [[UIImage alloc] initWithData:imgData];
        heart = [UIButton buttonWithType:UIButtonTypeCustom];
        heart.bounds = CGRectMake( 0, 0, image.size.width, image.size.height );
        [heart setImage:image forState:UIControlStateNormal];
        [heart addTarget:self action:@selector(heartPressed) forControlEvents:UIControlEventTouchUpInside];
        heart.frame = CGRectMake(0, 0, 29, 29);
        ((UINavigationItem*)self.navigationItem).rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:heart];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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

-(void)setPrefValue:(id)value specifier:(PSSpecifier*)spec
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:PLPATH];
    if(!dict)
        dict = [[NSMutableDictionary alloc]init];
    
    NSString *key = [spec propertyForKey:@"key"];
    if([key isEqualToString:@"kEnabled"])
    {
        for(PSSpecifier *specifier in _specifiers)
        {
            if(specifier->cellType != PSGroupCell && specifier != spec)
            {
                [specifier setProperty:value forKey:@"enabled"];
                [self reloadSpecifier:specifier];
            }
        }
    }
    
    [dict setValue:value forKey:[spec propertyForKey:@"key"]];
    [dict writeToFile:PLPATH atomically:YES];
    
    [spec setProperty:value forKey:@"default"];
    [self reloadSpecifier:spec];
}

-(id)readPrefValue:(PSSpecifier*)spec
{
    NSString *key = [spec propertyForKey:@"key"];
    id defaultValue = [spec propertyForKey:@"default"];
    
    id plistValue;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:PLPATH];
    if(dict)
        plistValue = [dict objectForKey:key];
    
    id value;
    if (!plistValue)
        value = defaultValue;
    else
        value = plistValue;
    
    if([[spec propertyForKey:@"key"]isEqualToString:@"kEnabled"])
    {
        for(PSSpecifier *specifier in _specifiers)
        {
            if(specifier->cellType != PSGroupCell && specifier != spec && ![specifier.name isEqualToString:@"Credits List"])
            {
                [specifier setProperty:value forKey:@"enabled"];
                [self reloadSpecifier:specifier];
            }
        }
    }
    
    return value;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return 90;
    else
        return UITableViewAutomaticDimension;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0,0,tableView.bounds.size.width, 100)];
        view.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth);
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(90,10,tableView.bounds.size.width-90, 60)];
        //label.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth);
        label.text = @"CirDock";
        label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:48];
        label.textAlignment = NSTextAlignmentCenter;
        [label sizeToFit];
        label.frame.size = CGSizeMake(label.frame.size.width, 60);
        
        UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(90,60,tableView.bounds.size.width-90, 40)];
        //label2.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth);
        label2.text = @"Amro Thabet\naka Brave Heart";
        label2.numberOfLines = 2;
        label2.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:24];
        label2.textAlignment = NSTextAlignmentCenter;
        label2.adjustsFontSizeToFitWidth = YES;
        label2.frame = CGRectMake(label.frame.origin.x, 60, label.frame.size.width, 40);
        
        NSData *imgData = [[NSData alloc] initWithContentsOfFile:@"/Library/PreferenceBundles/CirDockSettings.bundle/Icon-60.png"];
        UIImage *img = [[UIImage alloc] initWithData:imgData];
        UIImageView *imageView = [[UIImageView alloc]initWithImage:img];
        //imageView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin);
        imageView.frame = CGRectMake(60, 13, 90, 90);
        
        [view addSubview:label];
        [view addSubview:label2];
        [view addSubview:imageView];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label2.translatesAutoresizingMaskIntoConstraints = NO;
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *viewsDictionary = @{@"label":label, @"label2":label2, @"imageView":imageView};
        NSArray *constraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|->=0-[imageView(90)]-10-[label]->=0-|" options:0 metrics:nil views:viewsDictionary];
        
        [view addConstraints:constraint_POS_H];
        
        NSArray *constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-13-[imageView(90)]" options:0 metrics:nil views:viewsDictionary];
        [view addConstraints:constraint_POS_V];
        
        constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[label(60)]" options:0 metrics:nil views:viewsDictionary];
        [view addConstraints:constraint_POS_V];
        
        constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[label2(40)]" options:0 metrics:nil views:viewsDictionary];
        [view addConstraints:constraint_POS_V];
        
        constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[label]-(-10)-[label2]" options:0 metrics:nil views:viewsDictionary];
        [view addConstraints:constraint_POS_V];
        
        [view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1.f constant:60.f]];
        
        [view addConstraint:[NSLayoutConstraint constraintWithItem:label2 attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:label attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
        
        return view;
    }
    return nil;
}

- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[NSMutableArray alloc]init];
        
        PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [(NSMutableArray *)_specifiers addObject:specifier];
        
        if([[NSFileManager defaultManager]fileExistsAtPath:FIRSTRUNPATHSETTINGS])
        {
            specifier = [PSSpecifier preferenceSpecifierNamed:@"Tweak Settings" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
            [(NSMutableArray *)_specifiers addObject:specifier];
            
            specifier = [PSSpecifier preferenceSpecifierNamed:@"Enabled Applications" target:self set:nil get:nil detail:NSClassFromString(@"CirDockApplicationsController") cell:PSLinkCell edit:nil];
            [specifier setProperty:NSClassFromString(@"PSColoredCell") forKey:@"cellClass"];
            [specifier setProperty:@"center" forKey:@"align"];
            [specifier setProperty:[UIColor redColor] forKey:@"color"];
            [specifier setProperty:@YES forKey:@"enabled"];
            [(NSMutableArray *)_specifiers addObject:specifier];
            
            specifier = [PSSpecifier preferenceSpecifierNamed:@"Carousel Settings" target:self set:nil get:nil detail:NSClassFromString(@"CarouselSettingsController") cell:PSLinkCell edit:nil];
            [specifier setProperty:@YES forKey:@"enabled"];
            [specifier setProperty:NSClassFromString(@"PSColoredCell") forKey:@"cellClass"];
            [specifier setProperty:@"center" forKey:@"align"];
            [specifier setProperty:[UIColor orangeColor] forKey:@"color"];
            [(NSMutableArray *)_specifiers addObject:specifier];
            
            specifier = [PSSpecifier preferenceSpecifierNamed:@"Import/Export Settings" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
            [specifier setProperty:@"Place the settings file in /var/mobile/Library/ before importing. The exported settings file will be saved as CirDockSettings.CDS in /var/mobile/Library" forKey:@"footerText"];
            [specifier setProperty:@1 forKey:@"footerAlignment"];
            [(NSMutableArray *)_specifiers addObject:specifier];
            
            specifier = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSStaticTextCell edit:nil];
            [specifier setProperty:@YES forKey:@"enabled"];
            [specifier setProperty:NSClassFromString(@"PSIECell") forKey:@"cellClass"];
            [(NSMutableArray *)_specifiers addObject:specifier];
            
            specifier = [PSSpecifier preferenceSpecifierNamed:@"Extras" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
            [(NSMutableArray *)_specifiers addObject:specifier];
            
            specifier = [PSSpecifier preferenceSpecifierNamed:@"Respring" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
            [specifier setProperty:@YES forKey:@"enabled"];
            [specifier setProperty:NSClassFromString(@"PSColoredCell") forKey:@"cellClass"];
            [specifier setProperty:@"center" forKey:@"align"];
            [specifier setProperty:[UIColor redColor] forKey:@"color"];
            specifier->action = @selector(respring);
            [(NSMutableArray *)_specifiers addObject:specifier];
        }
        else
        {
            specifier = [PSSpecifier preferenceSpecifierNamed:@"Tweak Settings" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
            [specifier setProperty:@"You need to respring before being able to edit the tweak." forKey:@"footerText"];
            [specifier setProperty:@1 forKey:@"footerAlignment"];
            [(NSMutableArray *)_specifiers addObject:specifier];
            
            specifier = [PSSpecifier preferenceSpecifierNamed:@"Respring" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
            [specifier setProperty:@YES forKey:@"enabled"];
            [specifier setProperty:NSClassFromString(@"PSColoredCell") forKey:@"cellClass"];
            [specifier setProperty:@"center" forKey:@"align"];
            [specifier setProperty:[UIColor redColor] forKey:@"color"];
            specifier->action = @selector(respring);
            [(NSMutableArray *)_specifiers addObject:specifier];
            
            specifier = [PSSpecifier preferenceSpecifierNamed:@"Extras" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
            [(NSMutableArray *)_specifiers addObject:specifier];
        }
        
        specifier = [PSSpecifier preferenceSpecifierNamed:@"Request New Feature" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
        [specifier setProperty:@YES forKey:@"enabled"];
        [specifier setProperty:NSClassFromString(@"PSColoredCell") forKey:@"cellClass"];
        [specifier setProperty:@"center" forKey:@"align"];
        [specifier setProperty:[UIColor orangeColor] forKey:@"color"];
        specifier->action = @selector(requestFeat);
        [(NSMutableArray *)_specifiers addObject:specifier];
        
        specifier = [PSSpecifier preferenceSpecifierNamed:@"Acknowledgements & Special Thanks" target:self set:nil get:nil detail:NSClassFromString(@"AcknowledgementsController") cell:PSLinkCell edit:nil];
        [specifier setProperty:@YES forKey:@"enabled"];
        [specifier setProperty:NSClassFromString(@"PSColoredCell") forKey:@"cellClass"];
        [specifier setProperty:@"center" forKey:@"align"];
        [specifier setProperty:[UIColor redColor] forKey:@"color"];
        [(NSMutableArray *)_specifiers addObject:specifier];
        
        specifier = [PSSpecifier preferenceSpecifierNamed:@"Tutorial" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
        [specifier setProperty:@YES forKey:@"enabled"];
        [specifier setProperty:NSClassFromString(@"PSColoredCell") forKey:@"cellClass"];
        [specifier setProperty:@"center" forKey:@"align"];
        [specifier setProperty:[UIColor orangeColor] forKey:@"color"];
        specifier->action = @selector(displayTutorial);
        [(NSMutableArray *)_specifiers addObject:specifier];
        
        specifier = [PSSpecifier preferenceSpecifierNamed:@"Reset To Defaults" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
        [specifier setProperty:@YES forKey:@"enabled"];
        [specifier setProperty:NSClassFromString(@"PSColoredCell") forKey:@"cellClass"];
        [specifier setProperty:@"center" forKey:@"align"];
        [specifier setProperty:[UIColor redColor] forKey:@"color"];
        specifier->action = @selector(resetSettings);
        [(NSMutableArray *)_specifiers addObject:specifier];
    }
    return _specifiers;
}

- (void)resetSettings
{
    [UIAlertView showWithTitle:@"Reset to Defaults" message:@"Are you sure you want to reset all the settings to their defaults?" cancelButtonTitle:@"No" otherButtonTitles:@[@"Yes"] tapBlock:^(UIAlertView * alertView, NSInteger buttonIndex){
        if([[alertView buttonTitleAtIndex:buttonIndex]isEqual:@"Yes"])
        {
            NSMutableDictionary *dict = [[NSDictionary dictionaryWithContentsOfFile:PLPATH] mutableCopy];
            if(!dict)
                dict = [[NSMutableDictionary alloc]init];
            
            if ([[UIDevice currentDevice].model isEqualToString:@"iPod touch"]) //iPod
                [dict setObject:@[@"com.apple.MobileSMS", @"com.apple.mobilemail", @"com.apple.mobilesafari", @"com.apple.Music"] forKey:@"enabledApps"];
            else if (UI_USER_INTERFACE_IDIOM()!=UIUserInterfaceIdiomPad) //iPhone
                [dict setObject:@[@"com.apple.mobilephone", @"com.apple.mobilemail", @"com.apple.mobilesafari", @"com.apple.Music"] forKey:@"enabledApps"];
            else //iPad
                [dict setObject:@[@"com.apple.mobilesafari", @"com.apple.mobilemail", @"com.apple.videos", @"com.apple.Music"] forKey:@"enabledApps"];
            
            [dict setObject:@"3" forKey:@"kListValue"];
            [dict setObject:@"0" forKey:@"scrollAnimation"];
            [dict setObject:@[] forKey:@"favApps"];
            [dict setObject:@[] forKey:@"enabledLongHold"];
            [dict setObject:@NO forKey:@"badgeAllApps"];
            [dict setObject:@NO forKey:@"isGlowBGOn"];
            [dict setObject:[NSString stringWithFormat:@"rgba:%f:%f:%f:%f:0", 0.f, 0.f, 0.f, 1.f] forKey:@"GlowColor"];
            [dict setObject:@NO forKey:@"removeLabels"];
            [dict setObject:@NO forKey:@"removeBadges"];
            [dict setObject:@NO forKey:@"removeActionLabel"];
            [dict setObject:@(1) forKey:@"iconScale-portrait"];
            [dict setObject:@(1.2f) forKey:@"iconSpacing-portrait"];
            [dict setObject:@(1.2f) forKey:@"tilt-portrait"];
            [dict setObject:@(8) forKey:@"maxVisIcons-portrait"];
            [dict setObject:@(300.f) forKey:@"dockRadius-portrait"];
            [dict setObject:@(1) forKey:@"iconScale-landscape"];
            [dict setObject:@(1.4f) forKey:@"iconSpacing-landscape"];
            [dict setObject:@(1.4f) forKey:@"tilt-landscape"];
            [dict setObject:@(8) forKey:@"maxVisIcons-landscape"];
            [dict setObject:@(300.f) forKey:@"dockRadius-landscape"];
            
            [dict writeToFile:PLPATH atomically:YES];
            
            CFNotificationCenterRef centre = CFNotificationCenterGetDarwinNotifyCenter();
            CFNotificationCenterPostNotification( centre, (__bridge CFStringRef)@"CirDockCarouselChangeNotification", NULL, NULL, YES );
            CFNotificationCenterPostNotification( centre, (__bridge CFStringRef)@"CirDockAppsChangedNotification", NULL, NULL, YES );
            CFNotificationCenterPostNotification( centre, (__bridge CFStringRef)@"CirDockBadgeChangeNotification", NULL, NULL, YES );
            CFNotificationCenterPostNotification( centre, (__bridge CFStringRef)@"CirDockColorChangeNotification", NULL, NULL, YES );
            CFNotificationCenterPostNotification( centre, (__bridge CFStringRef)@"CirDockLabelChangeNotification", NULL, NULL, YES );
            
            [self reloadSpecifiers];
        }
    }];
}
@end

@interface AcknowledgementsController: PSListController {
}
@end

@implementation AcknowledgementsController
- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Acknowledgements" target:self];
    }
    return _specifiers;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:1 green:80.f/255.f blue:70.f/255.f alpha:1];
    [[UIApplication sharedApplication] keyWindow].tintColor = [UIColor colorWithRed:1 green:80.f/255.f blue:70.f/255.f alpha:1];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] keyWindow].tintColor = nil;
    self.view.tintColor = nil;
    self.navigationController.navigationBar.tintColor = nil;
}
@end

@interface CirDockListController : PSListItemsController
@end
@implementation CirDockListController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:1 green:80.f/255.f blue:70.f/255.f alpha:1];
    [[UIApplication sharedApplication] keyWindow].tintColor = [UIColor colorWithRed:1 green:80.f/255.f blue:70.f/255.f alpha:1];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] keyWindow].tintColor = nil;
    self.view.tintColor = nil;
    self.navigationController.navigationBar.tintColor = nil;
}
@end

@interface CarouselSettingsController: PSListController {
}
- (id)readPrefValue:(PSSpecifier*)spec;
- (void)setPrefValue:(id)value specifier:(PSSpecifier*)spec;
- (void)loadPreview:(NSTimer*)timer;
- (void)copyValues;
- (void)resetValues;

@property (nonatomic) BOOL addedCarousel;
@property (nonatomic, retain) PSSpecifier *differentiatedGroupCell, *buttonSpec;
@property (nonatomic, retain) NSArray *differentiatedGroupKeys;
@end

id getOrientation()
{
    id dictValue;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:PLPATH];
    if(dict)
    {
        dictValue = [dict valueForKey:@"currentEditOrientation"];
    }
    
    if(!dictValue)
        dictValue = @(0);
    
    return dictValue;
}

id setDifferentiatedCellsDefaultValue(int difference)
{
    id plistValue;
    switch (difference) // Set defaults
    {
        case 0: //dockRadius
        {
            plistValue = @(300.f);
            break;
        }
        case 1: //iconScale
        {
            plistValue = @(1);
            break;
        }
        case 2: //iconSpacing
        {
            plistValue = ([getOrientation() intValue] == 0)?@(1.2):@(1.4);
            break;
        }
        case 3: //max Visible Icons
        {
            plistValue = @(8);
            break;
        }
        case 4: //tilt
        {
            plistValue = @(0.9f);
            break;
        }
        default:
            break;
    }
    return plistValue;
}

@implementation CarouselSettingsController
@synthesize addedCarousel, differentiatedGroupCell, differentiatedGroupKeys, buttonSpec;

- (id)init
{
    self = [super init];
    if(self)
    {
        differentiatedGroupKeys = @[@"dockRadius", @"iconScale", @"iconSpacing", @"maxVisIcons", @"tilt"];
    }
    return self;
}

- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[NSMutableArray alloc]init];
        
        NSMutableDictionary *dict = [[NSDictionary dictionaryWithContentsOfFile:PLPATH] mutableCopy];
        
        PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"Preview" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [specifier setProperty:@"Note: This preview may not be as accurate as possible, so just use it as a quick reference." forKey:@"footerText"];
        [specifier setProperty:@1 forKey:@"footerAlignment"];
        [(NSMutableArray *)_specifiers addObject:specifier];
        
        specifier = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSSpinnerCell edit:nil];
        [specifier setProperty:@96 forKey:@"height"];
        [(NSMutableArray *)_specifiers addObject:specifier];
        
        specifier = [PSSpecifier preferenceSpecifierNamed:@"Dock Settings" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [(NSMutableArray *)_specifiers addObject:specifier];
        
        specifier = [PSSpecifier preferenceSpecifierNamed:@"Carousel Type" target:self set:@selector(setPrefValue:specifier:) get:@selector(readPrefValue:) detail:NSClassFromString(@"CirDockListController") cell:PSLinkListCell edit:nil];
        [specifier setProperty:@YES forKey:@"enabled"];
        [specifier setProperty:@"3" forKey:@"default"];
        [specifier setProperty:PLPATH forKey:@"defaults"];
        specifier.values = [NSArray arrayWithObjects:@"0",@"1",@"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10",nil];
        specifier.titleDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Linear", @"Rotary", @"Inverted Rotary", @"Cylinder", @"Inverted Cylinder", @"Wheel", @"Inverted Wheel", @"Cover Flow 1", @"Cover Flow 2", @"Time Machine", @"Inverted Time Machine",nil] forKeys:specifier.values];
        specifier.shortTitleDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Linear",@"Rotary",@"yratoR", @"Cylinder", @"rednilyC", @"Wheel", @"leehW", @"CoverF1", @"CoverF2", @"TimeMachine", @"enihcaMemiT",nil] forKeys:specifier.values];
        [specifier setProperty:@"kListValue" forKey:@"key"];
        [(NSMutableArray *)_specifiers addObject:specifier];
        
        specifier = [PSSpecifier preferenceSpecifierNamed:@"Dock Bounces?" target:self set:@selector(setPrefValue:specifier:) get:@selector(readPrefValue:) detail:nil cell:PSSwitchCell edit:nil];
        [specifier setProperty:NSClassFromString(@"PSCirDockSwitch") forKey:@"cellClass"];
        [specifier setProperty:@"bouncing" forKey:@"key"];
        [specifier setProperty:@YES forKey:@"default"];
        [(NSMutableArray *)_specifiers addObject:specifier];
        
        specifier = [PSSpecifier preferenceSpecifierNamed:@"Dock Scroll Animation" target:self set:@selector(setPrefValue:specifier:) get:@selector(readPrefValue:) detail:NSClassFromString(@"CirDockListController") cell:PSLinkListCell edit:nil];
        [specifier setProperty:@YES forKey:@"enabled"];
        [specifier setProperty:@"0" forKey:@"default"];
        [specifier setProperty:PLPATH forKey:@"defaults"];
        specifier.values = [NSArray arrayWithObjects:@"0",@"1",@"2", @"3", @"4", @"5", nil];
        specifier.titleDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"None", @"Bounce", @"Flip", @"Pulsate", @"Rotate", @"Wiggle",nil] forKeys:specifier.values];
        specifier.shortTitleDictionary = specifier.titleDictionary;
        [specifier setProperty:@"scrollAnimation" forKey:@"key"];
        [(NSMutableArray *)_specifiers addObject:specifier];
        
        specifier = [PSSpecifier preferenceSpecifierNamed:@"Dock Wraps?" target:self set:@selector(setPrefValue:specifier:) get:@selector(readPrefValue:) detail:nil cell:PSSwitchCell edit:nil];
        [specifier setProperty:NSClassFromString(@"PSCirDockSwitch") forKey:@"cellClass"];
        [specifier setProperty:@"wraps" forKey:@"key"];
        [specifier setProperty:@YES forKey:@"default"];
        [(NSMutableArray *)_specifiers addObject:specifier];
        
        specifier = [PSSpecifier preferenceSpecifierNamed:@"Return Icon" target:self set:@selector(setPrefValue:specifier:) get:@selector(readPrefValue:) detail:NSClassFromString(@"CirDockListController") cell:PSLinkListCell edit:nil];
        [specifier setProperty:@YES forKey:@"enabled"];
        [specifier setProperty:PLPATH forKey:@"defaults"];
        [specifier setProperty:@"" forKey:@"default"];
        NSMutableArray *values = [[NSMutableArray alloc] init];
        NSMutableArray *titles = [[NSMutableArray alloc] init];
        if(dict)
        {
            NSArray *enabledApps = dict[@"enabledApps"];
            if(enabledApps)
            {
                NSMutableDictionary *identifiers = [[[ALApplicationList sharedApplicationList] applicationsFilteredUsingPredicate:nil] mutableCopy];
                values = [[identifiers keysSortedByValueUsingComparator: ^(id obj1, id obj2) {
                    if (obj1 == nil)
                    {
                        return (NSComparisonResult)NSOrderedDescending; //obj1 is > than all rest
                    }
                    else if(obj2 == nil)
                    {
                        return (NSComparisonResult)NSOrderedAscending; //obj2 is > than all rest
                    }
                    
                    return [obj1 caseInsensitiveCompare:obj2];
                }] mutableCopy];
                values = [[values filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF IN %@", enabledApps ]] mutableCopy];
                
                for(NSString *value in values)
                {
                    [titles addObject:identifiers[value]];
                }
            }
        }
        [values insertObject:@"" atIndex:0];
        [titles insertObject:@"Default" atIndex:0];
        specifier.values = values;
        specifier.titleDictionary = [NSDictionary dictionaryWithObjects:titles forKeys:specifier.values];
        specifier.shortTitleDictionary = specifier.titleDictionary;
        [specifier setProperty:@"returnToIcon" forKey:@"key"];
        [(NSMutableArray *)_specifiers addObject:specifier];
        
        specifier = [PSSpecifier preferenceSpecifierNamed:@"Show Back Icons?" target:self set:@selector(setPrefValue:specifier:) get:@selector(readPrefValue:) detail:nil cell:PSSwitchCell edit:nil];
        [specifier setProperty:NSClassFromString(@"PSCirDockSwitch") forKey:@"cellClass"];
        [specifier setProperty:@"showBackface" forKey:@"key"];
        [specifier setProperty:@NO forKey:@"default"];
        [(NSMutableArray *)_specifiers addObject:specifier];
        
        specifier = [PSSpecifier preferenceSpecifierNamed:@"Vertical Landscape?" target:self set:@selector(setPrefValue:specifier:) get:@selector(readPrefValue:) detail:nil cell:PSSwitchCell edit:nil];
        [specifier setProperty:NSClassFromString(@"PSCirDockSwitch") forKey:@"cellClass"];
        [specifier setProperty:@"vertLandscape" forKey:@"key"];
        [(NSMutableArray *)_specifiers addObject:specifier];
        
        specifier = [PSSpecifier preferenceSpecifierNamed:@"Icon Settings" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [(NSMutableArray *)_specifiers addObject:specifier];
        
        specifier = [PSSpecifier preferenceSpecifierNamed:@"Remove Icon Labels" target:self set:@selector(setPrefValue:specifier:) get:@selector(readPrefValue:) detail:nil cell:PSSwitchCell edit:nil];
        [specifier setProperty:NSClassFromString(@"PSCirDockSwitch") forKey:@"cellClass"];
        [specifier setProperty:@"removeLabels" forKey:@"key"];
        [(NSMutableArray *)_specifiers addObject:specifier];
        
        specifier = [PSSpecifier preferenceSpecifierNamed:@"Remove Icon Badges" target:self set:@selector(setPrefValue:specifier:) get:@selector(readPrefValue:) detail:nil cell:PSSwitchCell edit:nil];
        [specifier setProperty:NSClassFromString(@"PSCirDockSwitch") forKey:@"cellClass"];
        [specifier setProperty:@"removeBadges" forKey:@"key"];
        [(NSMutableArray *)_specifiers addObject:specifier];
        
        specifier = [PSSpecifier preferenceSpecifierNamed:@"Highlight Running Apps?" target:self set:@selector(setPrefValue:specifier:) get:@selector(readPrefValue:) detail:nil cell:PSSwitchCell edit:nil];
        [specifier setProperty:NSClassFromString(@"PSCirDockSwitch") forKey:@"cellClass"];
        [specifier setProperty:@"isGlowBGOn" forKey:@"key"];
        [(NSMutableArray *)_specifiers addObject:specifier];
        
        BOOL isGlowBGOn = false;
        if(dict)
            isGlowBGOn = [[dict valueForKey:@"isGlowBGOn"] boolValue];
        
        if(isGlowBGOn)
        {
            specifier  = [PSSpecifier preferenceSpecifierNamed:@"Highlight Color" target:self set:nil get:nil detail:NSClassFromString(@"PSColorPicker") cell:PSLinkCell edit:nil];
            [specifier setProperty:@YES forKey:@"enabled"];
            [specifier setProperty:@YES forKey:@"isController"];
            [specifier setProperty:@"GlowColor" forKey:@"key"];
            [specifier setProperty:@"com.braveheart.cirdock" forKey:@"defaults"];
            [specifier setProperty:@"rgba:0:0:0:0:0" forKey:@"default"];
            [(NSMutableArray *)_specifiers addObject:specifier];
        }
        
        { // Differentiated settings specifiers
            specifier = [PSSpecifier preferenceSpecifierNamed:@"Differentiated Settings" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
            [specifier setProperty:@"This gives you the ability to configure values differently for portrait and landscape orientations. If count independant is set on, the features in this section will not depend on the number of icons enabled." forKey:@"footerText"];
            [specifier setProperty:@1 forKey:@"footerAlignment"];
            [(NSMutableArray *)_specifiers addObject:specifier];
            differentiatedGroupCell = specifier;
            
            // Obtaining Up/Down and Left/Right unicode characters
            UniChar upDownUnicode = 0x2195;
            NSString *upDownUnicodeString = [NSString stringWithCharacters:&upDownUnicode length:1];
            UniChar rightLeftUnicode = 0x2194;
            NSString *rightLeftUnicodeString = [NSString stringWithCharacters:&rightLeftUnicode length:1];
            NSString *portraitText = [NSString stringWithFormat:@"Portrait %@", upDownUnicodeString];
            NSString *landscapeText = [NSString stringWithFormat:@"Landscape %@", rightLeftUnicodeString];
            
            specifier = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:@selector(setPrefValue:specifier:) get:@selector(readPrefValue:) detail:nil cell:PSSegmentCell edit:nil];
            [specifier setProperty:@YES forKey:@"enabled"];
            [specifier setProperty:@"currentEditOrientation" forKey:@"key"];
            [specifier setValues:@[@(0), @(1)] titles:@[portraitText, landscapeText]];
            [specifier setProperty:@(0) forKey:@"default"];
            [(NSMutableArray *)_specifiers addObject:specifier];
            
            { //Dock Radius
                specifier = [PSSpecifier preferenceSpecifierNamed:@"Dock Radius:" target:self set:nil get:nil detail:nil cell:PSStaticTextCell edit:nil];
                [specifier setProperty:@YES forKey:@"enabled"];
                [specifier setProperty:NSClassFromString(@"PSColoredCell") forKey:@"cellClass"];
                [specifier setProperty:@"center" forKey:@"align"];
                [specifier setProperty:@"center" forKey:@"detail"];
                [specifier setProperty:[UIColor redColor] forKey:@"color"];
                [specifier setProperty:@22 forKey:@"height"];
                [(NSMutableArray *)_specifiers addObject:specifier];
                
                specifier = [PSSpecifier preferenceSpecifierNamed:@"Count Dependant?" target:self set:@selector(setPrefValue:specifier:) get:@selector(readPrefValue:) detail:nil cell:PSSwitchCell edit:nil];
                [specifier setProperty:NSClassFromString(@"PSCirDockSwitch") forKey:@"cellClass"];
                [specifier setProperty:@"countDependant" forKey:@"key"];
                [specifier setProperty:@YES forKey:@"default"];
                [(NSMutableArray *)_specifiers addObject:specifier];
                
                BOOL countDependant = true;
                if(dict)
                    countDependant = [[dict valueForKey:@"countDependant"] boolValue];
                
                if(!countDependant)
                {
                    specifier = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:@selector(setPrefValue:specifier:) get:@selector(readPrefValue:) detail:nil cell:PSSliderCell edit:nil];
                    [specifier setProperty:@(200.f) forKey:@"min"];
                    [specifier setProperty:@(700.f) forKey:@"max"];
                    [specifier setProperty:@(300.f) forKey:@"default"];
                    [specifier setProperty:@YES forKey:@"showValue"];
                    [specifier setProperty:@YES forKey:@"enabled"];
                    [specifier setProperty:@"dockRadius" forKey:@"key"];
                    [(NSMutableArray *)_specifiers addObject:specifier];
                }
            }
            
            { //Icon Scale
                specifier = [PSSpecifier preferenceSpecifierNamed:@"Icon Scale:" target:self set:nil get:nil detail:nil cell:PSStaticTextCell edit:nil];
                [specifier setProperty:@YES forKey:@"enabled"];
                [specifier setProperty:NSClassFromString(@"PSColoredCell") forKey:@"cellClass"];
                [specifier setProperty:@"center" forKey:@"align"];
                [specifier setProperty:[UIColor redColor] forKey:@"color"];
                [specifier setProperty:@22 forKey:@"height"];
                [(NSMutableArray *)_specifiers addObject:specifier];
                
                specifier = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:@selector(setPrefValue:specifier:) get:@selector(readPrefValue:) detail:nil cell:PSSliderCell edit:nil];
                [specifier setProperty:@(0.5f) forKey:@"min"];
                [specifier setProperty:@(1.5f) forKey:@"max"];
                [specifier setProperty:@(1) forKey:@"default"];
                [specifier setProperty:@YES forKey:@"showValue"];
                [specifier setProperty:@YES forKey:@"enabled"];
                [specifier setProperty:@"iconScale" forKey:@"key"];
                [(NSMutableArray *)_specifiers addObject:specifier];
            }
            
            { //Icon Spacing
                specifier = [PSSpecifier preferenceSpecifierNamed:@"Icon Spacing:" target:self set:nil get:nil detail:nil cell:PSStaticTextCell edit:nil];
                [specifier setProperty:@YES forKey:@"enabled"];
                [specifier setProperty:NSClassFromString(@"PSColoredCell") forKey:@"cellClass"];
                [specifier setProperty:@"center" forKey:@"align"];
                [specifier setProperty:[UIColor redColor] forKey:@"color"];
                [specifier setProperty:@22 forKey:@"height"];
                [(NSMutableArray *)_specifiers addObject:specifier];
                
                specifier = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:@selector(setPrefValue:specifier:) get:@selector(readPrefValue:) detail:nil cell:PSSliderCell edit:nil];
                [specifier setProperty:@(0) forKey:@"min"];
                [specifier setProperty:@(3) forKey:@"max"];
                [specifier setProperty:@(1.2) forKey:@"default"];
                [specifier setProperty:@YES forKey:@"showValue"];
                [specifier setProperty:@YES forKey:@"enabled"];
                [specifier setProperty:@"iconSpacing" forKey:@"key"];
                [(NSMutableArray *)_specifiers addObject:specifier];
            }
            
            { //Icon Tilt
                specifier = [PSSpecifier preferenceSpecifierNamed:@"Icon Tilt:" target:self set:nil get:nil detail:nil cell:PSStaticTextCell edit:nil];
                [specifier setProperty:@YES forKey:@"enabled"];
                [specifier setProperty:NSClassFromString(@"PSColoredCell") forKey:@"cellClass"];
                [specifier setProperty:@"center" forKey:@"align"];
                [specifier setProperty:[UIColor redColor] forKey:@"color"];
                [specifier setProperty:@22 forKey:@"height"];
                [(NSMutableArray *)_specifiers addObject:specifier];
                
                specifier = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:@selector(setPrefValue:specifier:) get:@selector(readPrefValue:) detail:nil cell:PSSliderCell edit:nil];
                [specifier setProperty:@(0.f) forKey:@"min"];
                [specifier setProperty:@(1.0f) forKey:@"max"];
                [specifier setProperty:@(0.9f) forKey:@"default"];
                [specifier setProperty:@YES forKey:@"showValue"];
                [specifier setProperty:@YES forKey:@"enabled"];
                [specifier setProperty:@"tilt" forKey:@"key"];
                [(NSMutableArray *)_specifiers addObject:specifier];
            }
            
            specifier = [PSSpecifier preferenceSpecifierNamed:@"Max Visible Icons" target:self set:@selector(setPrefValue:specifier:) get:@selector(readPrefValue:) detail:nil cell:PSStaticTextCell edit:nil];
            [specifier setProperty:@YES forKey:@"enabled"];
            [specifier setProperty:NSClassFromString(@"PSStepperCell") forKey:@"cellClass"];
            [specifier setProperty:@"red" forKey:@"colour"];
            [specifier setProperty:@"rgba:255.f:80.f:70.f:255.f:1" forKey:@"colour"];
            [specifier setProperty:@"maxVisIcons" forKey:@"key"];
            [specifier setProperty:@(8) forKey:@"default"];
            
            id pValue = dict[([getOrientation() intValue] == 0)?@"maxVisIcons-portrait":@"maxVisIcons-landscape"];
            if(pValue)
                [specifier setProperty:pValue forKey:@"default"];
            
            [specifier setProperty:@(2) forKey:@"minimumValue"];
            [specifier setProperty:@(20) forKey:@"maximumValue"];
            [specifier setProperty:@(1) forKey:@"stepValue"];
            [specifier setProperty:@"com.braveheart.cirdock" forKey:@"defaults"];
            [(NSMutableArray *)_specifiers addObject:specifier];
            
            specifier = [PSSpecifier preferenceSpecifierNamed:([getOrientation() intValue] == 0)?@"Copy Landscape Values":@"Copy Portrait Values" target:self set:nil get:@selector(readPrefValue:) detail:nil cell:PSButtonCell edit:nil];
            [specifier setProperty:@YES forKey:@"enabled"];
            [specifier setProperty:NSClassFromString(@"PSColoredCell") forKey:@"cellClass"];
            [specifier setProperty:@"center" forKey:@"align"];
            [specifier setProperty:[UIColor redColor] forKey:@"color"];
            [specifier setProperty:@"copyBtn" forKey:@"key"];
            specifier->action = @selector(copyValues);
            [(NSMutableArray *)_specifiers addObject:specifier];
            buttonSpec = specifier;
            
            specifier = [PSSpecifier preferenceSpecifierNamed:@"Reset Defaults" target:self set:nil get:@selector(readPrefValue:) detail:nil cell:PSButtonCell edit:nil];
            [specifier setProperty:@YES forKey:@"enabled"];
            [specifier setProperty:NSClassFromString(@"PSColoredCell") forKey:@"cellClass"];
            [specifier setProperty:@"center" forKey:@"align"];
            [specifier setProperty:[UIColor redColor] forKey:@"color"];
            specifier->action = @selector(resetValues);
            [(NSMutableArray *)_specifiers addObject:specifier];
        }
        
        {
            // Advanced settings specifiers
            specifier = [PSSpecifier preferenceSpecifierNamed:@"Advanced Settings" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
            [specifier setProperty:@"Defaults are 0.85 for Deceleration Rate, 0.002 for Icon Perspective, and 1.0 for Scroll Speed." forKey:@"footerText"];
            [specifier setProperty:@1 forKey:@"footerAlignment"];
            [(NSMutableArray *)_specifiers addObject:specifier];
            differentiatedGroupCell = specifier;
            
            { //Deceleration Rate
                specifier = [PSSpecifier preferenceSpecifierNamed:@"Deceleration Rate:" target:self set:nil get:nil detail:nil cell:PSStaticTextCell edit:nil];
                [specifier setProperty:@YES forKey:@"enabled"];
                [specifier setProperty:NSClassFromString(@"PSColoredCell") forKey:@"cellClass"];
                [specifier setProperty:@"center" forKey:@"align"];
                [specifier setProperty:[UIColor redColor] forKey:@"color"];
                [specifier setProperty:@22 forKey:@"height"];
                [(NSMutableArray *)_specifiers addObject:specifier];
                
                specifier = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:@selector(setPrefValue:specifier:) get:@selector(readPrefValue:) detail:nil cell:PSSliderCell edit:nil];
                [specifier setProperty:@(0.0f) forKey:@"min"];
                [specifier setProperty:@(1.0f) forKey:@"max"];
                [specifier setProperty:@(0.85f) forKey:@"default"];
                [specifier setProperty:@YES forKey:@"showValue"];
                [specifier setProperty:@YES forKey:@"enabled"];
                [specifier setProperty:@"decelerationRate" forKey:@"key"];
                [(NSMutableArray *)_specifiers addObject:specifier];
            }
            
            { //Perspective
                specifier = [PSSpecifier preferenceSpecifierNamed:@"Icon Perspective:" target:self set:nil get:nil detail:nil cell:PSStaticTextCell edit:nil];
                [specifier setProperty:@YES forKey:@"enabled"];
                [specifier setProperty:NSClassFromString(@"PSColoredCell") forKey:@"cellClass"];
                [specifier setProperty:@"center" forKey:@"align"];
                [specifier setProperty:[UIColor redColor] forKey:@"color"];
                [specifier setProperty:@22 forKey:@"height"];
                [(NSMutableArray *)_specifiers addObject:specifier];
                
                specifier = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:@selector(setPrefValue:specifier:) get:@selector(readPrefValue:) detail:nil cell:PSSliderCell edit:nil];
                [specifier setProperty:@(0.002f) forKey:@"min"];
                [specifier setProperty:@(0.01f) forKey:@"max"];
                [specifier setProperty:@(0.002) forKey:@"default"];
                [specifier setProperty:@YES forKey:@"showValue"];
                [specifier setProperty:@YES forKey:@"enabled"];
                [specifier setProperty:@"perspective" forKey:@"key"];
                [(NSMutableArray *)_specifiers addObject:specifier];
            }
            
            { //Scroll Speed
                specifier = [PSSpecifier preferenceSpecifierNamed:@"Scroll Speed:" target:self set:nil get:nil detail:nil cell:PSStaticTextCell edit:nil];
                [specifier setProperty:@YES forKey:@"enabled"];
                [specifier setProperty:NSClassFromString(@"PSColoredCell") forKey:@"cellClass"];
                [specifier setProperty:@"center" forKey:@"align"];
                [specifier setProperty:[UIColor redColor] forKey:@"color"];
                [specifier setProperty:@22 forKey:@"height"];
                [(NSMutableArray *)_specifiers addObject:specifier];
                
                specifier = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:@selector(setPrefValue:specifier:) get:@selector(readPrefValue:) detail:nil cell:PSSliderCell edit:nil];
                [specifier setProperty:@(0.5f) forKey:@"min"];
                [specifier setProperty:@(3.0f) forKey:@"max"];
                [specifier setProperty:@(1) forKey:@"default"];
                [specifier setProperty:@YES forKey:@"showValue"];
                [specifier setProperty:@YES forKey:@"enabled"];
                [specifier setProperty:@"scrollSpeed" forKey:@"key"];
                [(NSMutableArray *)_specifiers addObject:specifier];
            }
        }
        
        specifier = [PSSpecifier preferenceSpecifierNamed:@"Hold Action Settings" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [specifier setProperty:@"These hold actions are filters that will filter the dock when you long hold it from anywhere. Currently, you can set it off, or choose a mix between it being off, filtered by if the application has a badge, or if the application is one of your favorites." forKey:@"footerText"];
        [specifier setProperty:@1 forKey:@"footerAlignment"];
        [(NSMutableArray *)_specifiers addObject:specifier];
        
        specifier = [PSSpecifier preferenceSpecifierNamed:@"Remove Action Label" target:self set:@selector(setPrefValue:specifier:) get:@selector(readPrefValue:) detail:nil cell:PSSwitchCell edit:nil];
        [specifier setProperty:NSClassFromString(@"PSCirDockSwitch") forKey:@"cellClass"];
        [specifier setProperty:@"removeActionLabel" forKey:@"key"];
        [(NSMutableArray *)_specifiers addObject:specifier];
        
        specifier = [PSSpecifier preferenceSpecifierNamed:@"Item Hold Actions" target:self set:nil get:nil detail:NSClassFromString(@"CirDockHoldController") cell:PSLinkCell edit:nil];
        [specifier setProperty:@YES forKey:@"enabled"];
        [(NSMutableArray *)_specifiers addObject:specifier];
        
        [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(loadPreview:) userInfo:nil repeats:NO];
    }
    return _specifiers;
}

- (void)copyValues
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:PLPATH];
    if(dict)
    {
        NSString *orientationString = @"";
        if([getOrientation() intValue] == 0) // Portrait
        {
            orientationString = @"landscape"; // INVERTED STRING
        }
        else // Landscape
        {
            orientationString = @"portrait"; //INVERTED STRING
        }
        
        NSArray *cellsInGroup = [self specifiersInGroup:2];
        for(PSSpecifier *tempSpec in cellsInGroup)
        {
            NSString *tempKey = [tempSpec propertyForKey:@"key"];
            NSInteger index = [differentiatedGroupKeys indexOfObject:tempKey];
            if(index == NSNotFound || index >= differentiatedGroupKeys.count)
                continue;
            
            id dictValue = [dict valueForKey:[NSString stringWithFormat:@"%@-%@", tempKey, orientationString]];
            if(!dictValue)
            {
                dictValue = setDifferentiatedCellsDefaultValue(index);
            }
            
            [tempSpec setProperty:dictValue forKey:@"default"];
            [self setPrefValue:dictValue specifier:tempSpec];
        }
    }
}

- (void)resetValues
{
    NSArray *cellsInGroup = [self specifiersInGroup:2];
    for(PSSpecifier *tempSpec in cellsInGroup)
    {
        NSString *tempKey = [tempSpec propertyForKey:@"key"];
        NSInteger index = [differentiatedGroupKeys indexOfObject:tempKey];
        if(index == NSNotFound || index >= differentiatedGroupKeys.count)
            continue;
        
        id dictValue = setDifferentiatedCellsDefaultValue(index);
        [tempSpec setProperty:dictValue forKey:@"default"];
        [self setPrefValue:dictValue specifier:tempSpec];
    }
}

- (void)loadPreview:(NSTimer*)timer
{
    [timer invalidate];
    
    PSSpecifier *spec = _specifiers[1];
    PSSpecifier *groupSpec = _specifiers[0];
    if(spec->cellType == PSSpinnerCell)
    {
        [self removeSpecifier:spec animated:YES];
        
        PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSStaticTextCell edit:nil];
        [specifier setProperty:@YES forKey:@"enabled"];
        [specifier setProperty:NSClassFromString(@"PSCarouselCell") forKey:@"cellClass"];
        [specifier setProperty:@96 forKey:@"height"];
        
        [self insertSpecifier:specifier afterSpecifier:groupSpec animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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

-(void)setPrefValue:(id)value specifier:(PSSpecifier*)spec
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:PLPATH];
    if(!dict)
        dict = [[NSMutableDictionary alloc]init];
    
    NSString *key = [spec propertyForKey:@"key"];
    if([key isEqualToString:@"kEnabled"])
    {
        for(PSSpecifier *specifier in _specifiers)
        {
            if(specifier->cellType != PSGroupCell && specifier != spec)
            {
                [specifier setProperty:value forKey:@"enabled"];
                [self reloadSpecifier:specifier];
            }
        }
    } 
    
    if([differentiatedGroupKeys containsObject:key])
    {
        NSString *orientationString = @"";
        if([getOrientation() intValue] == 0) // Portrait
        {
            orientationString = @"portrait";
        }
        else // Landscape
        {
            orientationString = @"landscape";
        }
        
        [dict setValue:value forKey:[NSString stringWithFormat:@"%@-%@", key, orientationString]];
    }
    else
        [dict setValue:value forKey:key];
    
    [dict writeToFile:PLPATH atomically:YES];
    
    [spec setProperty:value forKey:@"default"];
    [self reloadSpecifier:spec];
    
    if([key isEqualToString:@"kListValue"])
    {
        CFNotificationCenterRef centre = CFNotificationCenterGetDarwinNotifyCenter();
        CFNotificationCenterPostNotification( centre, (__bridge CFStringRef)@"CirDockCarouselChangeNotification", NULL, NULL, YES );
    }
    else if([key isEqualToString:@"scrollAnimation"] || [key isEqualToString:@"showBackface"] || [key isEqualToString:@"wraps"] || [key isEqualToString:@"decelerationRate"] || [key isEqualToString:@"perspective"] || [key isEqualToString:@"scrollSpeed"] || [key isEqualToString:@"bouncing"])
    {
        CFNotificationCenterRef centre = CFNotificationCenterGetDarwinNotifyCenter();
        CFNotificationCenterPostNotification( centre, (__bridge CFStringRef)@"CirDockDockChangedNotification", NULL, NULL, YES );
    }
    else if([key isEqualToString:@"isGlowBGOn"])
    {
        if([value boolValue] == YES)
        {
            PSSpecifier *specifier	= [PSSpecifier preferenceSpecifierNamed:@"Highlight Color" target:self set:nil get:nil detail:NSClassFromString(@"PSColorPicker") cell:PSLinkCell edit:nil];
            [specifier setProperty:@YES forKey:@"enabled"];
            [specifier setProperty:@YES forKey:@"isController"];
            [specifier setProperty:@"GlowColor" forKey:@"key"];
            [specifier setProperty:@"com.braveheart.cirdock" forKey:@"defaults"];
            [specifier setProperty:@"rgba:0:0:0:0:0" forKey:@"default"];
            [self insertSpecifier:specifier afterSpecifier:spec animated:YES];
        }
        else
            [self removeSpecifierAtIndex:([self indexOfSpecifier:spec]+1) animated:YES];
        
        CFNotificationCenterRef centre = CFNotificationCenterGetDarwinNotifyCenter();
        CFNotificationCenterPostNotification( centre, (__bridge CFStringRef)@"CirDockAppsChangedNotification", NULL, NULL, YES );
    }
    else if([key isEqualToString:@"countDependant"])
    {
        if([value boolValue] == NO)
        {
            PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:@selector(setPrefValue:specifier:) get:@selector(readPrefValue:) detail:nil cell:PSSliderCell edit:nil];
            [specifier setProperty:@(200.f) forKey:@"min"];
            [specifier setProperty:@(700.f) forKey:@"max"];
            [specifier setProperty:@(300.f) forKey:@"default"];
            [specifier setProperty:@YES forKey:@"showValue"];
            [specifier setProperty:@YES forKey:@"enabled"];
            [specifier setProperty:@"dockRadius" forKey:@"key"];
            [self insertSpecifier:specifier afterSpecifier:spec animated:YES];
        }
        else
            [self removeSpecifierAtIndex:([self indexOfSpecifier:spec]+1) animated:YES];
        
        CFNotificationCenterRef centre = CFNotificationCenterGetDarwinNotifyCenter();
        CFNotificationCenterPostNotification( centre, (__bridge CFStringRef)@"CirDockDockChangedNotification", NULL, NULL, YES );
    }
    else if([key isEqualToString:@"removeActionLabel"])
    {
        CFNotificationCenterRef centre = CFNotificationCenterGetDarwinNotifyCenter();
        CFNotificationCenterPostNotification( centre, (__bridge CFStringRef)@"CirDockLabelChangeNotification", NULL, NULL, YES );
    }
    else if([key isEqualToString:@"removeLabels"] || [key isEqualToString:@"removeBadges"])
    {
        CFNotificationCenterRef centre = CFNotificationCenterGetDarwinNotifyCenter();
        CFNotificationCenterPostNotification( centre, (__bridge CFStringRef)@"CirDockAppsChangedNotification", NULL, NULL, YES );
    }
    else if([key isEqualToString:@"currentEditOrientation"])
    {
        // Reload Differentiated Settings Section
        // 0 - Group Cell
        // 1 - Segment Cell
        // 2 - Dock Height
        // 3 - Icon Scale
        // 4 - Icon Spacing
        // 5 - Max Visible Icons (PSStepperCell)
        // 6 - Copy Values Button
        
        NSString *orientationString = @"";
        NSString *buttonTitle = @"";
        if([value intValue] == 0) // Portrait
        {
            orientationString = @"portrait";
            buttonTitle = @"Copy Landscape Values";
        }
        else // Landscape
        {
            orientationString = @"landscape";
            buttonTitle = @"Copy Portrait Values";
        }
        
        //int groupIndex = [self indexOfSpecifier:differentiatedGroupCell];
        NSArray *cellsInGroup = [self specifiersInGroup:2];
        for(PSSpecifier *tempSpec in cellsInGroup) //From Icon Scale to Max Visible Icons
        {
            NSString *tempKey = [tempSpec propertyForKey:@"key"];
            NSInteger index = [differentiatedGroupKeys indexOfObject:tempKey];
            if(index == NSNotFound || index >= differentiatedGroupKeys.count)
                continue;
            
            id dictValue = [dict valueForKey:[NSString stringWithFormat:@"%@-%@", tempKey, orientationString]];
            if(!dictValue)
            {
                dictValue = setDifferentiatedCellsDefaultValue(index);
            }
            
            [tempSpec setProperty:dictValue forKey:@"default"];
            [self reloadSpecifier:tempSpec];
        }
        [buttonSpec setName:buttonTitle];
        [self reloadSpecifier:buttonSpec];
    }
    else if([differentiatedGroupKeys containsObject:key])
    {
        CFNotificationCenterRef centre = CFNotificationCenterGetDarwinNotifyCenter();
        CFNotificationCenterPostNotification( centre, (__bridge CFStringRef)@"CirDockDockChangedNotification", NULL, NULL, YES );
    }
}

-(id)readPrefValue:(PSSpecifier*)spec
{
    NSString *key = [spec propertyForKey:@"key"];
    
    if([key isEqualToString:@"copyBtn"])
    {
        if([getOrientation() intValue] == 0)
        {
            [spec setName:@"Copy Landscape Values"];
        }
        else
        {
            [spec setName:@"Copy Portrait Values"];
        }
        return nil;
    }
    
    id defaultValue = [spec propertyForKey:@"default"];
    
    id plistValue;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:PLPATH];
    if(dict)
    {
        if([differentiatedGroupKeys containsObject:key])
        {
            NSString *orientationString = @"";
            if([getOrientation() intValue] == 0) // Portrait
            {
                orientationString = @"portrait";
            }
            else // Landscape
            {
                orientationString = @"landscape";
            }
            
            int difference = [differentiatedGroupKeys indexOfObject:key];
            plistValue = [dict objectForKey:[NSString stringWithFormat:@"%@-%@", key, orientationString]];
            if(!plistValue)
            {
                plistValue = setDifferentiatedCellsDefaultValue(difference);
            }
        }
        else
            plistValue = [dict objectForKey:key];
    }
    
    id value;
    if (!plistValue)
        value = defaultValue;
    else
        value = plistValue;
    
    if([[spec propertyForKey:@"key"]isEqualToString:@"kEnabled"])
    {
        for(PSSpecifier *specifier in _specifiers)
        {
            if(specifier->cellType != PSGroupCell && specifier != spec && ![specifier.name isEqualToString:@"Credits List"])
            {
                [specifier setProperty:value forKey:@"enabled"];
                [self reloadSpecifier:specifier];
            }
        }
    }
    
    return value;
}

- (void)reloadSpecifiers
{
    [super reloadSpecifiers];
    
//    for (PSSpecifier *spec in _specifiers)
//    {
//        [self setPrefValue:[self readPrefValue:spec] specifier:spec];
//    }
}

@end

// vim:ft=objc
