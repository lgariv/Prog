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
+(instancetype)SLM_sharedInstance;
-(void)publishBulletinRequest:(BBBulletinRequest*)arg1 destinations:(unsigned long long)arg2;
@end

static BBServer *sharedServer;
#include <dlfcn.h>
extern dispatch_queue_t __BBServerQueue;

%hook BBServer
%new
+(id)SLM_sharedInstance {
    return sharedServer;
}
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

		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
			SBIconImageView *viewview = (SBIconImageView*)self.superview;
			// while (viewview == nil) SBIconImageView *viewview = self.superview;
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
				[bulletin setSection:@"com.reddit.Reddit"];
				[bulletin setSectionID:@"com.reddit.Reddit"];
				
				[bulletin setBulletinID:bulletinUUID];
				[bulletin setRecordID:bulletinUUID];
				[bulletin setPublisherBulletinID:@"com.example.notification"];
				[bulletin setDate:[NSDate date]];
				[bulletin setClearable:YES];
				// [bulletin setLockScreenPriority:9223372036854775807];

				// dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
					dispatch_async(__BBServerQueue, ^{
						[sharedServer publishBulletinRequest:bulletin destinations:2];
					});
				// });
			}
		});
	}
	return self;
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

@interface NCNotificationContentView : UIView
@property (nonatomic, strong) NSString *primaryText;
@property (nonatomic, strong) UILabel *secondaryLabel;
@property (nonatomic, strong) NSString *secondaryText;
@end 

@interface PLPlatterCustomContentView : UIView
@end

%hook PLPlatterCustomContentView
-(id)initWithAncestorPlatterView:(__kindof UIView *)arg1 {
	%orig;
	/*if ([self.subviews[0] isKindOfClass:[%c(NCNotificationContentView) class]]) {
		NCNotificationContentView *view = self.subviews[0];
		if ([view.secondaryText isEqualToString:@"progress bar"]) {
			view.secondaryLabel.alpha = 0;
		} else {
			return %orig;
		}
	}*/
	return self;
}
%end

static NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

@interface UILabel (extra)
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) NSProgress *progress;
-(void)progressBar:(UIProgressView*)progressBarView progress:(NSProgress*)progress ;
@end


%hook UILabel
%property (nonatomic, strong) UIProgressView *progressView;
%property (nonatomic, strong) NSProgress *progress;

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setText:(NSString *)arg1 {
	%orig;
	if ([arg1 isEqualToString:@"com.miwix.downloadbar14-progressbar"]) {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(receiveNotification:) 
												     name:@"updateProgress"
												   object:nil];
		[self setAlpha:0];
		// dict = [@{ (NSString*)[(NCNotificationContentView*)self.superview.superview primaryText] : @{ @"view" : self.superview, @"frame" : [NSValue valueWithCGRect:self.bounds] } } mutableCopy];
		// dict = @{};
		// [dict addEntriesFromDictionary:addToDict];
		NSProgress *progress = [NSProgress progressWithTotalUnitCount:100];
		UIProgressView *progressBarView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
		[progress setCompletedUnitCount:0];
		progressBarView.observedProgress = progress;
		self.progressView = progressBarView;
		self.progress = progress;
		[self progressBar:self.progressView progress:self.progress];
	}
}

%new
-(void)receiveNotification:(NSNotification *)notification {
	NSDictionary* userInfo = notification.userInfo;
	double fraction = [userInfo[@"fraction"] doubleValue];
	NSLog(@"[TESTTES] fraction: %f", fraction);
	[self.progress setCompletedUnitCount:(fraction*100)];
	[self progressBar:self.progressView progress:self.progress];
}

%new
-(void)progressBar:(UIProgressView*)progressBarView progress:(NSProgress*)progress {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		progressBarView.progressTintColor = [UIColor systemBlueColor];
		progressBarView.trackTintColor = [UIColor lightGrayColor];

		[progressBarView setFrame:self.frame];
		[progressBarView setCenter:CGPointMake(self.superview.center.x, self.superview.center.y+18)];
		[self.superview.superview addSubview:progressBarView];
	});
}
%end

/*%hook NCNotificationContentView
-(void)setPrimaryText:(NSString *)arg1 {
	%orig;
	if ([[dict allKeys] count] >= 1) {
		for (NSString *title in [dict allKeys]) {
			if ([arg1 isEqualToString:title]) {
				NSDictionary *innerDict = dict[title];
				UIProgressView *progressBarView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
				progressBarView.progressTintColor = [UIColor systemBlueColor];
				progressBarView.trackTintColor = [UIColor whiteColor];
				[progressBarView setProgress:(float)(10/100) animated:NO];  //15%
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
					[progressBarView setFrame:[innerDict[@"frame"] CGRectValue]];
					[self addSubview:progressBarView];
					[progressBarView setProgress:(float)(50/100) animated:YES];  //15%
				});
				break;
			}
		}
	}
}
%end*/
