@import UIKit;
@import Foundation;

@interface SButton : UIButton
@property (nonatomic,retain) UIViewController *controllerToDismiss;
@end

@implementation SButton
@end

#import <UIKit/UIColor.h>

@interface UIColor (cat)
- (UIColor *)inverseColor ;
@end

@implementation UIColor (cat)
- (UIColor *)inverseColor {
    CGFloat alpha;

    CGFloat red, green, blue;
    if ([self getRed:&red green:&green blue:&blue alpha:&alpha]) {
        return [UIColor colorWithRed:1.0 - red green:1.0 - green blue:1.0 - blue alpha:alpha];
    }

    CGFloat hue, saturation, brightness;
    if ([self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
        return [UIColor colorWithHue:1.0 - hue saturation:1.0 - saturation brightness:1.0 - brightness alpha:alpha];
    }

    CGFloat white;
    if ([self getWhite:&white alpha:&alpha]) {
        return [UIColor colorWithWhite:1.0 - white alpha:alpha];
    }

    return nil;
}
@end

%hook CSCoverSheetViewController
-(void)viewDidDisappear:(BOOL)arg1 {
    %orig;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.miwix.prog.donate" object:nil userInfo:nil];
}
%end

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDonateController:) name:@"com.miwix.prog.donate" object:nil];
}

%new
- (void)showDonateController:(NSNotification *)notification {
    static dispatch_once_t progOnceToken;
    dispatch_once(&progOnceToken, ^{
        NSString *valueForMyKey;
        @try {
            valueForMyKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"progFirstTime"];
            NSLog(@"[Prog] valueForMyKey:%@", valueForMyKey);
            // [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"progFirstTime"];
        }
        @catch ( NSException *exception ) {
            if (exception) {
                NSLog(@"[Prog] ERROR:%@", exception);
            }
            valueForMyKey = @"YES";
        }
        if ([valueForMyKey isEqualToString:@"YES"] || [[NSUserDefaults standardUserDefaults] objectForKey:@"progFirstTime"] == nil) {
            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"progFirstTime"];
            UIViewController *donateController = [[UIViewController alloc] init];
            [[donateController view] setBackgroundColor:[UIColor systemBackgroundColor]];

            UIStackView *stackView = [[UIStackView alloc] initWithFrame:CGRectMake(0, 0, [donateController view].frame.size.width, [donateController view].frame.size.width)];
            stackView.axis = UILayoutConstraintAxisVertical;
            stackView.alignment = UIStackViewAlignmentCenter;
            stackView.distribution = UIStackViewDistributionEqualSpacing;
            stackView.layoutMarginsRelativeArrangement = YES;
            stackView.spacing = 15;

            UIImage *iconImage = [UIImage imageWithContentsOfFile:@"/Library/Application Support/ProgExtra.bundle/icon.png"];
            UIImageView *iconImageView = [[UIImageView alloc] initWithImage:iconImage];
            [iconImageView setFrame:CGRectMake(0, 0, 100.0f, 100.0f)];
            [iconImageView setTranslatesAutoresizingMaskIntoConstraints:YES];
            [iconImageView.widthAnchor constraintEqualToAnchor:nil constant:[[UIScreen mainScreen] bounds].size.width/4.0f].active = YES;
            [iconImageView.heightAnchor constraintEqualToAnchor:nil constant:[[UIScreen mainScreen] bounds].size.width/4.0f].active = YES;

            UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100.0f, 100.0f)];
            NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:@"Thank you for installing Prog!\nWe hope you'll enjoy it😁\n\nProg has been in the works for over 2 months, and is inspired by the\nr/Jailbreak community.\n\nIf you appreciate our work, please consider making a small donation."];
            [attributedText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0f weight:UIFontWeightHeavy] range:NSMakeRange(0,31)];
            [attributedText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0f] range:NSMakeRange(32, 187)];
            textLabel.attributedText = attributedText;
            textLabel.textColor = [UIColor labelColor];
            textLabel.textAlignment = NSTextAlignmentCenter;
            textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            textLabel.numberOfLines = 0;

            SButton *donateButton = [SButton buttonWithType:UIButtonTypeSystem];
            [donateButton setFrame:CGRectMake(0, 0, 250.0f, 50.0f)]; // Notch Series
            [donateButton setTranslatesAutoresizingMaskIntoConstraints:NO];
            [donateButton.widthAnchor constraintEqualToAnchor:nil constant:[[UIScreen mainScreen] bounds].size.width/1.5f].active = YES;
            [donateButton.heightAnchor constraintEqualToAnchor:nil constant:([[UIScreen mainScreen] bounds].size.width/1.5f)/5.0f].active = YES;
            [donateButton setTitle:@"Donate" forState:UIControlStateNormal];
            [donateButton setBackgroundColor:[UIColor colorWithRed:254.0f/255.0f green:197.0f/255.0f blue:48.0f/255.0f alpha:1.0f]];
            [[donateButton titleLabel] setFont:[UIFont systemFontOfSize:19]];
            [[donateButton layer] setCornerRadius:10.5];
            [donateButton setTintColor:[[UIColor labelColor] inverseColor]];
            [donateButton addTarget:self action:@selector(buttonDonate:) forControlEvents:UIControlEventTouchUpInside];
            donateButton.controllerToDismiss = donateController;

            SButton *closeButton = [SButton buttonWithType:UIButtonTypeClose];
            [closeButton setFrame:CGRectMake(0, 0, 30.0f, 30.0f)];
            [closeButton addTarget:self action:@selector(buttonDismiss:) forControlEvents:UIControlEventTouchUpInside];
            closeButton.controllerToDismiss = donateController;

            [stackView addArrangedSubview:iconImageView];
            [stackView addArrangedSubview:textLabel];
            [stackView addArrangedSubview:donateButton];
            [[donateController view] addSubview:stackView];
            [[donateController view] addSubview:closeButton];

            // // Constraints
            [stackView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [stackView.centerXAnchor constraintEqualToAnchor:[donateController view].centerXAnchor constant:0].active = YES;
            [stackView.centerYAnchor constraintEqualToAnchor:[donateController view].centerYAnchor constant:-10.0f].active = YES;
            [stackView.widthAnchor constraintEqualToAnchor:[donateController view].widthAnchor constant:[[UIScreen mainScreen] bounds].size.width/1.15f].active = YES;
            [textLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            [textLabel.widthAnchor constraintEqualToAnchor:nil constant:[[UIScreen mainScreen] bounds].size.width/1.3f].active = YES;
            [closeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
            [closeButton.topAnchor constraintEqualToAnchor:[donateController view].topAnchor constant:10.0f].active = YES;
            [closeButton.trailingAnchor constraintEqualToAnchor:[donateController view].trailingAnchor constant:-10.0f].active = YES;

            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:donateController animated:YES completion:nil];
            donateController.modalInPopover = YES;
        }
    });
}

%new
-(void)buttonDonate:(UIButton *)sender {
    SButton *senderFix = sender;
    [senderFix.controllerToDismiss dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=DSAQ8SXMGFUNU&source=url"]];
}

%new
-(void)buttonDismiss:(UIButton *)sender {
    SButton *senderFix = sender;
    [senderFix.controllerToDismiss dismissViewControllerAnimated:YES completion:nil];
}
%end
