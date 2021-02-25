@interface SButton : UIButton
@property (nonatomic,retain) UIViewController *controllerToDismiss;    
@end

@implementation SButton
@end

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDonateController:) name:@"com.miwix.selenium.donate" object:nil];
}

%new
- (void)showDonateController:(NSNotification *)notification {
    static dispatch_once_t progOnceToken;
    dispatch_once(&progOnceToken, ^{
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"progFirstTime"] isEqualToString:@"YES"] || [[NSUserDefaults standardUserDefaults] objectForKey:@"progFirstTime"] == nil) {
            [[NSUserDefaults standardUserDefaults] setValue:@"NO" forKey:@"progFirstTime"];
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
            NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:@"Thank you for installing Prog!\n We hope you'll enjoy it😁\n\n Prog has been in the works for 2 months, and is inspired by the r/Jailbreak community.\n\n If you appreciate our work, please consider making a small donation."];
            [attributedText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0f weight:UIFontWeightHeavy] range:NSMakeRange(0,35)];
            [attributedText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0f] range:NSMakeRange(36,262)];
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
            [donateButton setTintColor:[UIColor whiteColor]];
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

            // Constraints
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.miwix.selenium.resume.home" object:nil userInfo:nil];
}

%new
-(void)buttonDismiss:(UIButton *)sender {
    SButton *senderFix = sender;
    [senderFix.controllerToDismiss dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.miwix.selenium.resume.home" object:nil userInfo:nil];
}
%end