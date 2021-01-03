@import Foundation;
@import UIKit;
@import UserNotifications;

#import <UserNotifications/UserNotifications.h>

@interface BBBulletin : NSObject
@property (nonatomic,readonly) NSString * sectionDisplayName;
@property (nonatomic,copy) NSString * header;
@property (nonatomic,copy) NSString * section;
@property (nonatomic,copy) NSString * sectionID;
@property (nonatomic,copy) NSSet * subsectionIDs;
@property (nonatomic,copy) NSString * recordID;
@property (nonatomic,copy) NSString * publisherBulletinID;
@property (nonatomic,copy) NSString * dismissalID;
@property (nonatomic,copy) NSString * categoryID;
@property (nonatomic,copy) NSString * threadID;
@property (nonatomic,copy) NSArray * peopleIDs;
@property (nonatomic,copy) NSString * bulletinID;
@property (nonatomic,retain) NSDate *lastInterruptDate;
@property (assign,nonatomic) BOOL clearable;
@property (nonatomic,retain) NSDate *date;
@property (nonatomic,copy) NSString *message;
@property (nonatomic,retain) NSDate *publicationDate;
@property (assign,nonatomic) BOOL showsMessagePreview;
@property (nonatomic,copy) NSString *title;
+(id)bulletinWithBulletin:(id)arg1 ;
-(void)setLockScreenPriority:(long long)arg1 ;
-(BOOL)prioritizeAtTopOfLockScreen ;
@end

@interface BBBulletinRequest : BBBulletin
-(void)generateNewBulletinID;
@end

@interface BBServer : NSObject
-(void)publishBulletinRequest:(BBBulletinRequest*)arg1 destinations:(unsigned long long)arg2;
@end

static BBServer *sharedServer;
#include <dlfcn.h>
extern dispatch_queue_t __BBServerQueue;

%hook BBServer
-(id)initWithQueue:(id)arg1 {
    sharedServer = %orig;
    return sharedServer;
}
%end

#define PROGRESSBAR_INSET 7

@interface SBIconProgressView : UIView
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UIView *progressBar;
@property (nonatomic, strong) UIView *progressBarBackground;
@property (nonatomic, strong) NSString *downApp;
@property (nonatomic, assign) double displayedFraction;
-(void)setupSubviews;
@end

@interface SBIcon : NSObject
@property (nonatomic, strong) NSString *displayName;
@end

@interface SBDownloadingIcon : NSObject
@property (nonatomic, strong) NSString *realDisplayName;
@end

@interface SBIconImageView : UIView
@property (nonatomic,readonly) __kindof SBIcon *icon;
@end

%hook SBIconProgressView
%property (nonatomic, strong) UILabel *progressLabel;
%property (nonatomic, strong) UIView *progressBar;
%property (nonatomic, strong) UIView *progressBarBackground;
%property (nonatomic, strong) NSString *downApp;

-(void)setFrame:(CGRect)arg1 {
	%orig;
	if (arg1.size.width != 0) {
		[self setupSubviews];
	}
}

-(id)initWithFrame:(CGRect)arg1 {
	if ((self = %orig)) {
		self.progressBar = [[UIView alloc] init];
		self.progressBar.backgroundColor = [UIColor colorWithRed:67.f/255.f green:130.f/255.f blue:232.f/255.f alpha:1.0f];
		self.progressBar.layer.cornerRadius = 2.5;

		self.progressBarBackground = [[UIView alloc] init];
		self.progressBarBackground.backgroundColor = UIColor.darkGrayColor;
		self.progressBarBackground.layer.cornerRadius = 2.5;

		self.progressLabel = [[UILabel alloc] init];
		self.progressLabel.font = [UIFont boldSystemFontOfSize:10];
		self.progressLabel.textAlignment = NSTextAlignmentCenter;
		self.progressLabel.text = @"0%%";

		[self addSubview: self.progressBarBackground];
		[self addSubview: self.progressBar];
		[self addSubview: self.progressLabel];
	}
	return self;
}

-(void)didMoveToSuperview{
	%orig;
	
	SBIconImageView *viewview = (SBIconImageView*)self.superview;
	if (viewview != nil) {
		SBIcon *icon = [viewview icon];
		if (icon.displayName != nil) self.downApp = icon.displayName;
		BBBulletinRequest *bulletin = [[BBBulletinRequest alloc] init];
		[bulletin setHeader:@"APP STORE"];
		[bulletin setTitle:[NSString stringWithFormat:@"Downloading %@", (self.downApp != nil) ? self.downApp : icon.displayName]];
		[bulletin setMessage:@"com.miwix.downloadbar14-progressbar"];
		
		NSString *bulletinUUID = [[NSUUID UUID] UUIDString];
		
		//Temporary Fix because AppStore Notifications don't work on my device
		//[bulletin setSection:@"com.apple.AppStore"];
		//[bulletin setSectionID:@"com.apple.AppStore"];
		[bulletin setSection:@"com.apple.Preferences"];
		[bulletin setSectionID:@"com.apple.Preferences"];
		
		[bulletin setBulletinID:bulletinUUID];
		[bulletin setRecordID:bulletinUUID];
		[bulletin setPublisherBulletinID:@"com.miwix.downloadbar14"];
		[bulletin setDate:[NSDate date]];
		[bulletin setClearable:YES];
		
		dispatch_async(__BBServerQueue, ^{
			[sharedServer publishBulletinRequest:bulletin destinations:2];
		});
	}
}

-(void)setDisplayedFraction:(double)arg1 {
	%orig;
	self.progressLabel.text = [NSString stringWithFormat:@"%i%%", (int)(arg1 * 100)];
	self.progressLabel.textColor = [UIColor whiteColor];
	[self.progressLabel sizeToFit];

	NSDictionary* userInfo = @{ @"fraction" : [NSNumber numberWithDouble: arg1] };
	[[NSNotificationCenter defaultCenter] postNotificationName:@"updateProgress" object:nil userInfo:userInfo];
}

-(void)_drawOutgoingCircleWithCenter:(CGPoint)arg1 {

}

-(void)_drawIncomingCircleWithCenter:(CGPoint)arg1 {

}

-(void)_drawPauseUIWithCenter:(CGPoint)arg1 {
	%orig(CGPointMake(arg1.x, arg1.y - 10));
}

-(void)_drawPieWithCenter:(CGPoint)arg1 {
	self.progressLabel.center = CGPointMake(arg1.x, arg1.y + 7);
	self.progressBar.frame = CGRectMake(PROGRESSBAR_INSET, self.frame.size.height - 12, (self.frame.size.width - PROGRESSBAR_INSET * 2) * self.displayedFraction, 5);
	self.progressBarBackground.frame = CGRectMake(PROGRESSBAR_INSET, self.frame.size.height - 12, self.frame.size.width - PROGRESSBAR_INSET * 2, 5);
}

%new
-(void)setupSubviews {
	self.progressBarBackground.frame = CGRectMake(PROGRESSBAR_INSET, self.frame.size.height - 12, self.frame.size.width - PROGRESSBAR_INSET * 2, 5);
	self.progressBar.frame = CGRectMake(PROGRESSBAR_INSET, self.frame.size.height - 12, (self.frame.size.width - PROGRESSBAR_INSET * 2) * self.displayedFraction, 5);
	self.progressLabel.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 + 7);
}
%end

@interface PLPlatterView : UIView
@end

@interface NCNotificationRequest : NSObject
@property BBBulletin *bulletin;
@end

@interface NCNotificationViewControllerView : UIView
@property PLPlatterView *contentView;
@end

@interface NCNotificationContentView : UIView
@property(getter=_secondaryLabel,nonatomic,readonly) UILabel *secondaryLabel;
@end

@interface NCNotificationShortLookView : PLPlatterView
@property(getter=_notificationContentView,nonatomic,readonly) NCNotificationContentView *notificationContentView;
@end

@interface NCNotificationShortLookViewController : UIViewController
@property NCNotificationRequest *notificationRequest;

@property NSProgress *progress;
@end

%hook NCNotificationShortLookViewController
%property(nonatomic, strong) NSProgress *progress;

-(void)viewDidLoad{
	%orig;
	
	self.progress = [NSProgress progressWithTotalUnitCount:100];
}

-(void)viewDidAppear:(BOOL)animated{
	%orig;
	
	if ([self.notificationRequest.bulletin.publisherBulletinID isEqualToString:@"com.miwix.downloadbar14"]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"updateProgress" object:nil];
		
		UILabel *label = ((NCNotificationShortLookView*)((NCNotificationViewControllerView*)self.view).contentView).notificationContentView.secondaryLabel;
		label.alpha = 0;
		
		UIProgressView *progressBarView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
		[self.progress setCompletedUnitCount:0];
		progressBarView.observedProgress = self.progress;
		
		progressBarView.progressTintColor = [UIColor systemBlueColor];
		progressBarView.trackTintColor = [UIColor lightGrayColor];
		
		[progressBarView setFrame:label.frame];
		[progressBarView setCenter:CGPointMake(label.superview.center.x, label.superview.center.y+18)];
		[label.superview.superview addSubview:progressBarView];
	}
}

%new
-(void)receiveNotification:(NSNotification *)notification {
	NSDictionary* userInfo = notification.userInfo;
	double fraction = [userInfo[@"fraction"] doubleValue];
	[self.progress setCompletedUnitCount:(fraction*100)];
}
%end
