@import Foundation;
@import UIKit;
@import UserNotifications;

#import <UserNotifications/UserNotifications.h>

@interface BBSectionIconVariant : NSObject
@property (nonatomic,copy) NSData * imageData;
@end

@interface BBSectionIcon : NSObject
-(void)addVariant:(BBSectionIconVariant *)arg1 ;
@end

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

@interface SBApplication : NSObject
@property NSString *displayName;
@end

@interface SBApplicationController : NSObject
-(SBApplication*)applicationWithBundleIdentifier:(NSString*)identifier;

+(instancetype)sharedInstance;
@end

@interface SBIconProgressView : UIView
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UIView *progressBar;
@property (nonatomic, strong) UIView *progressBarBackground;
@property (nonatomic, strong) NSString *bundleId;
@property (nonatomic, assign) double displayedFraction;
-(void)setupSubviews;
@end

@interface SBIcon : NSObject
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *uniqueIdentifier;
@end

@interface SBDownloadingIcon : NSObject
@property (nonatomic, strong) NSString *realDisplayName;
@end

@interface SBIconImageView : UIView
@property (nonatomic,readonly) __kindof SBIcon *icon;
@end

static NSMutableDictionary<NSString*, NSProgress*> *progressDictionary;

%hook SBIconProgressView
%property (nonatomic, strong) UILabel *progressLabel;
%property (nonatomic, strong) UIView *progressBar;
%property (nonatomic, strong) UIView *progressBarBackground;
%property (nonatomic, strong) NSString *bundleId;

-(id)initWithFrame:(CGRect)arg1 {
	if ((self = %orig)) {
		self.progressBar = [[UIView alloc] init];
		self.progressBar.translatesAutoresizingMaskIntoConstraints = false;
		self.progressBar.backgroundColor = [UIColor colorWithRed:67.f/255.f green:130.f/255.f blue:232.f/255.f alpha:1.0f];
		self.progressBar.layer.cornerRadius = 2.5;

		self.progressBarBackground = [[UIView alloc] init];
		self.progressBarBackground.translatesAutoresizingMaskIntoConstraints = false;
		self.progressBarBackground.backgroundColor = UIColor.darkGrayColor;
		self.progressBarBackground.layer.cornerRadius = 2.5;

		self.progressLabel = [[UILabel alloc] init];
		self.progressLabel.translatesAutoresizingMaskIntoConstraints = false;
		self.progressLabel.font = [UIFont boldSystemFontOfSize:10];
		self.progressLabel.textAlignment = NSTextAlignmentCenter;
		self.progressLabel.text = @"0%%";

		[self addSubview: self.progressBarBackground];
		[self addSubview: self.progressBar];
		[self addSubview: self.progressLabel];

		[self setupSubviews];
	}
	return self;
}

-(void)setDisplayedFraction:(double)arg1 {
	%orig;
	self.progressLabel.text = [NSString stringWithFormat:@"%i%%", (int)(arg1 * 100)];
	self.progressLabel.textColor = [UIColor whiteColor];
	for(NSLayoutConstraint *width in self.constraints){
		if(width.firstAnchor == self.progressBar.widthAnchor || width.secondAnchor == self.progressBar.widthAnchor){
			width.active = false;
			break;
		}
	}

	[NSLayoutConstraint constraintWithItem:self.progressBar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.progressBarBackground attribute:NSLayoutAttributeWidth multiplier:CGFloat(arg1) constant:0].active = true;
}

-(void)_drawOutgoingCircleWithCenter:(CGPoint)arg1 {}

-(void)_drawIncomingCircleWithCenter:(CGPoint)arg1 {}

-(void)_drawPauseUIWithCenter:(CGPoint)arg1 {
	%orig(CGPointMake(arg1.x, arg1.y - 10));
}

-(void)_drawPieWithCenter:(CGPoint)arg1 {}

%new
-(void)setupSubviews {
	[self.progressBarBackground.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:PROGRESSBAR_INSET].active = true;
	[self.progressBarBackground.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-PROGRESSBAR_INSET].active = true;
	[self.progressBarBackground.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-PROGRESSBAR_INSET].active = true;
	[self.progressBarBackground.heightAnchor constraintEqualToConstant:5].active = true;

	[self.progressBar.leadingAnchor constraintEqualToAnchor:self.progressBarBackground.leadingAnchor].active = true;
	[self.progressBar.widthAnchor constraintEqualToConstant:0].active = true;
	[self.progressBar.topAnchor constraintEqualToAnchor:self.progressBarBackground.topAnchor].active = true;
	[self.progressBar.bottomAnchor constraintEqualToAnchor:self.progressBarBackground.bottomAnchor].active = true;

	[self.progressLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = true;
	[self.progressLabel.bottomAnchor constraintEqualToAnchor:self.progressBarBackground.topAnchor constant:-2].active = true;
}
%end



/*	<================================================================================================================================>	*/



@interface LSApplicationProxy : NSObject
@property(nonatomic, readonly, strong) NSString *applicationIdentifier;
@end

@protocol FBSApplicationPlaceholderProgress <NSObject>
@end

@interface FBSApplicationPlaceholderProgress : NSObject <FBSApplicationPlaceholderProgress>
@end

@interface FBSApplicationPlaceholder : NSObject
@property NSString *bundleIdentifier;
@property(nonatomic, readonly, strong) NSObject<FBSApplicationPlaceholderProgress> *progress;
@end

%hook FBSApplicationPlaceholder
-(instancetype)_initWithApplicationProxy:(id)proxy{
	FBSApplicationPlaceholder *instance = %orig;
	
	[[NSNotificationCenter defaultCenter] addObserver:instance selector:@selector(installsStarted:) name:@"installsStarted" object:nil];

	return instance;
}

%new
-(void)installsStarted:(NSNotification*)notification{
	NSArray<NSString*> *identifiers = notification.userInfo[@"identifiers"];

	/*NSString *desc = [NSString stringWithFormat:@"%@", self.progress];

	#pragma clang diagnostic push
	#pragma clang diagnostic ignored "-Wdeprecated-declarations"
	
	dispatch_async(dispatch_get_main_queue(), ^{
		UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@", desc] preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction* dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {}];
		[alert addAction:dismissAction];
		[[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alert animated:YES completion:nil];
	});
	
	#pragma clang diagnostic pop*/

	if([identifiers containsObject:self.bundleIdentifier] && [self.progress isKindOfClass:%c(FBSApplicationPlaceholderProgress)]){
		if(!progressDictionary) progressDictionary = [[NSMutableDictionary alloc] init];

		progressDictionary[self.bundleIdentifier] = MSHookIvar<NSProgress*>(self.progress, "_progress");

		BBBulletinRequest *bulletin = [[BBBulletinRequest alloc] init];
		[bulletin setHeader:[[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:self.bundleIdentifier].displayName];
		[bulletin setTitle:@"Downloading"];
		[bulletin setMessage:@"com.miwix.downloadbar14-progressbar"];
		
		NSString *bulletinUUID = [[NSUUID UUID] UUIDString];
		
		[bulletin setSection:@"com.apple.Preferences"];
		[bulletin setSectionID:@"com.apple.Preferences"];
		
		[bulletin setBulletinID:bulletinUUID];
		[bulletin setRecordID:bulletinUUID];
		[bulletin setThreadID:self.bundleIdentifier];
		[bulletin setPublisherBulletinID:[NSString stringWithFormat:@"com.miwix.downloadbar14/%@", self.bundleIdentifier]];
		[bulletin setDate:[NSDate date]];
		
		dispatch_async(__BBServerQueue, ^{
			[sharedServer publishBulletinRequest:bulletin destinations:2];
		});
	}
}
%end

%hook FBSApplicationLibrary
-(void)applicationInstallsDidStart:(id)installs{
	%orig;

	//[[NSNotificationCenter defaultCenter] postNotificationName:@"installsStarted" object:nil userInfo:@{}];

	NSMutableArray<NSString*> *identifiers = [[NSMutableArray alloc] init];
	for(LSApplicationProxy *proxy in installs){
		[identifiers addObject:proxy.applicationIdentifier];
	}

	[[NSNotificationCenter defaultCenter] postNotificationName:@"installsStarted" object:nil userInfo:@{@"identifiers": identifiers}];

	/*#pragma clang diagnostic push
	#pragma clang diagnostic ignored "-Wdeprecated-declarations"
	
	dispatch_async(dispatch_get_main_queue(), ^{
		UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@", installs] preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction* dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {}];
		[alert addAction:dismissAction];
		[[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alert animated:YES completion:nil];
	});
	
	#pragma clang diagnostic pop*/
}
%end



/*	<================================================================================================================================>	*/



@interface UIImage()
+(instancetype)_applicationIconImageForBundleIdentifier:(NSString*)bundleId format:(int)format;
@end

%hook BBBulletin
-(BBSectionIcon *)sectionIcon{
	if ([self.publisherBulletinID hasPrefix:@"com.miwix.downloadbar14/"]) {
		UIImage *img = [UIImage _applicationIconImageForBundleIdentifier:[self.publisherBulletinID substringFromIndex:[self.publisherBulletinID rangeOfString:@"/"].location + 1] format:1];

		BBSectionIconVariant *variant = [[BBSectionIconVariant alloc] init];
		[variant setImageData:UIImagePNGRepresentation(img)];

		BBSectionIcon *icon = [[BBSectionIcon alloc] init];
		[icon addVariant:variant];

		return icon;
	} else return %orig;
}
%end



/*	<================================================================================================================================>	*/



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
@property(getter=_secondaryTextView,nonatomic,readonly) UITextView *secondaryTextView;
@end

@interface NCNotificationShortLookView : PLPlatterView
@property(getter=_notificationContentView,nonatomic,readonly) NCNotificationContentView *notificationContentView;
@end

@interface NCNotificationLongLookView : UIView
@end

@interface NCNotificationViewController : UIViewController
@property NCNotificationRequest *notificationRequest;

@property UIProgressView *progressView;

-(void)resetContent;
@end

@interface NCNotificationShortLookViewController : NCNotificationViewController
@end

@interface NCNotificationLongLookViewController : NCNotificationViewController
@end

%hook NCNotificationShortLookViewController
%property(nonatomic, strong) UIProgressView *progressView;

-(void)viewWillAppear:(BOOL)animated{
	%orig;

	if ([self.notificationRequest.bulletin.publisherBulletinID hasPrefix:@"com.miwix.downloadbar14/"]) {
		if(!self.progressView) {
			self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
		}
		
		self.progressView.observedProgress = progressDictionary[[self.notificationRequest.bulletin.publisherBulletinID substringFromIndex:[self.notificationRequest.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]];

		NCNotificationContentView *content = ((NCNotificationShortLookView*)((NCNotificationViewControllerView*)self.view).contentView).notificationContentView;
		UILabel *label = content.secondaryLabel;
		label.hidden = true;
		
		self.progressView.translatesAutoresizingMaskIntoConstraints = false;
		
		self.progressView.progressTintColor = [UIColor systemBlueColor];
		self.progressView.trackTintColor = [UIColor lightGrayColor];
		
		[self.progressView removeFromSuperview];
		[content addSubview:self.progressView];
		
		[self.progressView.centerYAnchor constraintEqualToAnchor:label.centerYAnchor].active = true;
		[self.progressView.leadingAnchor constraintEqualToAnchor:label.leadingAnchor].active = true;
		[self.progressView.trailingAnchor constraintEqualToAnchor:label.trailingAnchor].active = true;
	}
}

%new
-(void)resetContent{
	[self.progressView removeFromSuperview];
	((NCNotificationShortLookView*)((NCNotificationViewControllerView*)self.view).contentView).notificationContentView.secondaryLabel.hidden = false;
}
%end

%hook NCNotificationLongLookViewController
%property(nonatomic, strong) UIProgressView *progressView;

-(void)viewWillAppear:(BOOL)animated{
	%orig;

	[self.progressView removeFromSuperview];

	if ([self.notificationRequest.bulletin.publisherBulletinID hasPrefix:@"com.miwix.downloadbar14/"]) {
		if(!self.progressView) {
			self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
		}
		
		self.progressView.observedProgress = progressDictionary[[self.notificationRequest.bulletin.publisherBulletinID substringFromIndex:[self.notificationRequest.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]];

		NCNotificationContentView *content = MSHookIvar<NCNotificationContentView*>(MSHookIvar<NCNotificationLongLookView*>(self, "_lookView"), "_notificationContentView");
		UITextView *label = content.secondaryTextView;
		label.hidden = true;
		
		self.progressView.translatesAutoresizingMaskIntoConstraints = false;
		
		self.progressView.progressTintColor = [UIColor systemBlueColor];
		self.progressView.trackTintColor = [UIColor lightGrayColor];
		
		[content addSubview:self.progressView];
		
		[self.progressView.centerYAnchor constraintEqualToAnchor:label.centerYAnchor].active = true;
		[self.progressView.leadingAnchor constraintEqualToAnchor:label.leadingAnchor].active = true;
		[self.progressView.trailingAnchor constraintEqualToAnchor:label.trailingAnchor].active = true;
	}
}

%new
-(void)resetContent{
	[self.progressView removeFromSuperview];
	MSHookIvar<NCNotificationContentView*>(MSHookIvar<NCNotificationLongLookView*>(self, "_lookView"), "_notificationContentView").secondaryTextView.hidden = false;
}
%end

@interface NCNotificationListCell : UIView
@property NCNotificationViewController *contentViewController;
@end

%hook NCNotificationListCell
-(void)didMoveToSuperview{
	%orig;

	if([self.contentViewController.notificationRequest.bulletin.publisherBulletinID hasPrefix:@"com.miwix.downloadbar14/"]) {
		self.contentViewController.progressView.observedProgress = progressDictionary[[self.contentViewController.notificationRequest.bulletin.publisherBulletinID substringFromIndex:[self.contentViewController.notificationRequest.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]];
	} else{
		[self.contentViewController resetContent];
	}
}

-(void)didMoveToWindow{
	%orig;

	if([self.contentViewController.notificationRequest.bulletin.publisherBulletinID hasPrefix:@"com.miwix.downloadbar14/"]) {
		self.contentViewController.progressView.observedProgress = progressDictionary[[self.contentViewController.notificationRequest.bulletin.publisherBulletinID substringFromIndex:[self.contentViewController.notificationRequest.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]];
	} else{
		[self.contentViewController resetContent];
	}
}
%end