@import Foundation;
@import UIKit;

#import <UIKit/UIKit.h>

@interface BBSectionIconVariant : NSObject
@property (nonatomic,copy) NSData * imageData;
@end

@interface BBSectionIcon : NSObject
-(void)addVariant:(BBSectionIconVariant *)arg1 ;
@end

@interface BBAction : NSObject
@property (nonatomic,copy) NSString * identifier;
@property (nonatomic,copy) NSURL * launchURL;
@property (nonatomic,copy) NSString * launchBundleID;
@property (assign,nonatomic) long long actionType;
+(id)actionWithIdentifier:(id)arg1 title:(id)arg2 ;
+(id)actionWithLaunchURL:(id)arg1 ;
+(id)actionWithLaunchBundleID:(id)arg1 ;
-(void)setCanBypassPinLock:(BOOL)arg1 ;
-(void)setShouldDismissBulletin:(BOOL)arg1 ;
@end

@interface BBBulletin : NSObject
@property (nonatomic,copy) BBAction * defaultAction; 
@property (nonatomic,retain) NSMutableDictionary * supplementaryActionsByLayout;
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

@interface BBServer : NSObject
-(void)publishBulletin:(BBBulletin*)arg1 destinations:(unsigned long long)arg2;
-(void)_clearBulletinIDs:(id)arg1 forSectionID:(id)arg2 shouldSync:(BOOL)arg3 ;
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

static NSMutableDictionary<NSString*, FBSApplicationPlaceholderProgress*> *progressDictionary;
NSMutableDictionary<NSString*, BBBulletin*> *bulletinDictionary;

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

-(void)_drawPieWithCenter:(CGPoint)arg1 {}

-(void)_drawPauseUIWithCenter:(CGPoint)arg1 {
	%orig(CGPointMake(arg1.x, arg1.y - 10));
}

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

#pragma mark Handling App Installation Queues, Postint Push Notfiications

@interface LSApplicationProxy : NSObject
@property(nonatomic, readonly, strong) NSString *applicationIdentifier;
@end

@protocol FBSApplicationPlaceholderProgress <NSObject>
@end

@interface FBSBundleInfo : NSObject
@property NSString *bundleIdentifier;
@property (nonatomic,copy,readonly) NSString * displayName;
@property (nonatomic,readonly) NSURL * bundleURL;
@end

@interface FBSApplicationPlaceholder : FBSBundleInfo
@property(getter=isPrioritizable) BOOL prioritizable;
@property(getter=isPausable) BOOL pausable;
@property(getter=isResumable) BOOL resumable;
@property(getter=isCancellable) BOOL cancellable;
@property(nonatomic, readonly, strong) NSObject<FBSApplicationPlaceholderProgress> *progress;
-(void)prioritize;
-(void)pause;
-(void)resume;
-(void)cancel;
@end

@interface FBSApplicationPlaceholderProgress : NSObject <FBSApplicationPlaceholderProgress>
@property FBSApplicationPlaceholder *placeholder;
@property(nonatomic, strong) NSDate *installStartedDate;
@property(nonatomic, strong) NSDate *installEndedDate;
@property(nonatomic, strong) NSDate *pauseDate;
@property(nonatomic, strong) NSNumber *pausedDuration;
@end

@interface SBLockScreenManager : NSObject
-(void)lockScreenViewControllerRequestsUnlock;
-(BOOL)isUILocked;
+(instancetype)sharedInstanceIfExists;
@end

%hook FBSApplicationPlaceholderProgress
%property(nonatomic, strong) NSDate *installStartedDate;
%property(nonatomic, strong) NSDate *installEndedDate;
%property(nonatomic, strong) NSDate *pauseDate;
%property(nonatomic, strong) NSNumber *pausedDuration;
%end

@interface BBResponse : NSObject
-(void)setSendBlock:(id)arg1 ;
@end

%hook FBSApplicationPlaceholder
-(instancetype)_initWithApplicationProxy:(id)proxy{
	FBSApplicationPlaceholder *instance = %orig;

	[[NSNotificationCenter defaultCenter] addObserver:instance selector:@selector(installsStarted:) name:@"installsStarted" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:instance selector:@selector(installsFinished:) name:@"installsFinished" object:nil];

	return instance;
}

-(void)_pauseWithResult:(id)result{
	if([self.progress isKindOfClass:%c(FBSApplicationPlaceholderProgress)]) ((FBSApplicationPlaceholderProgress*)self.progress).pauseDate = NSDate.date;

	%orig;

	BBBulletin *bulletin = bulletinDictionary[self.bundleIdentifier];
	NSMutableArray *actionsArray = bulletin.supplementaryActionsByLayout[@(0)];
	BBAction *entryToRemove;
	for (BBAction *entry in actionsArray) {
		if ([entry.identifier isEqualToString:@"pause_app_action"])
			entryToRemove = entry;
	}
	[actionsArray removeObject:entryToRemove];
	BBAction *resumeAction = [BBAction actionWithIdentifier:@"resume_app_action" title:@"Resume"];
	[resumeAction setActionType:2];
	[resumeAction setCanBypassPinLock:YES];
	[resumeAction setShouldDismissBulletin:NO];
	[actionsArray insertObject:resumeAction atIndex:1];
	[bulletin setSupplementaryActionsByLayout:[@{@(0) : actionsArray} mutableCopy]];

	dispatch_async(__BBServerQueue, ^{
		[sharedServer publishBulletin:bulletin destinations:4];
	});
}

-(void)_resumeWithResult:(id)result{
	if([self.progress isKindOfClass:%c(FBSApplicationPlaceholderProgress)] && ((FBSApplicationPlaceholderProgress*)self.progress).pauseDate) {
		((FBSApplicationPlaceholderProgress*)self.progress).pausedDuration = @(((FBSApplicationPlaceholderProgress*)self.progress).pausedDuration.doubleValue + -((FBSApplicationPlaceholderProgress*)self.progress).pauseDate.timeIntervalSinceNow);
		((FBSApplicationPlaceholderProgress*)self.progress).pauseDate = NULL;
	}

	%orig;

	BBBulletin *bulletin = bulletinDictionary[self.bundleIdentifier];
	NSMutableArray *actionsArray = bulletin.supplementaryActionsByLayout[@(0)];
	BBAction *entryToRemove;
	for (BBAction *entry in actionsArray) {
		if ([entry.identifier isEqualToString:@"resume_app_action"])
			entryToRemove = entry;
	}
	[actionsArray removeObject:entryToRemove];
	BBAction *resumeAction = [BBAction actionWithIdentifier:@"pause_app_action" title:@"Pause"];
	[resumeAction setActionType:2];
	[resumeAction setCanBypassPinLock:YES];
	[resumeAction setShouldDismissBulletin:NO];
	[actionsArray insertObject:resumeAction atIndex:1];
	[bulletin setSupplementaryActionsByLayout:[@{@(0) : actionsArray} mutableCopy]];

	dispatch_async(__BBServerQueue, ^{
		[sharedServer publishBulletin:bulletin destinations:4];
	});
}

-(void)_cancelWithResult:(id)result{
	%orig;

	NSString *bulletinUUID = bulletinDictionary[self.bundleIdentifier].bulletinID;
	dispatch_async(__BBServerQueue, ^{
		[sharedServer _clearBulletinIDs:@[bulletinUUID] forSectionID:bulletinUUID shouldSync:YES];
	});
}

%new
-(void)installsStarted:(NSNotification*)notification{
	NSArray<NSString*> *identifiers = notification.userInfo[@"identifiers"];

	if([identifiers containsObject:self.bundleIdentifier] && [self.progress isKindOfClass:%c(FBSApplicationPlaceholderProgress)]){
		if(!progressDictionary) progressDictionary = [[NSMutableDictionary alloc] init];
		if(!bulletinDictionary) bulletinDictionary = [[NSMutableDictionary alloc] init];

		((FBSApplicationPlaceholderProgress*)self.progress).installStartedDate = NSDate.date;
		progressDictionary[self.bundleIdentifier] = (FBSApplicationPlaceholderProgress*)self.progress;
		BBBulletin *bulletin = [[BBBulletin alloc] init];
		[bulletin setHeader:self.displayName];
		[bulletin setTitle:@"Downloading"];
		[bulletin setMessage:@"com.miwix.downloadbar14-progressbar\ncom.miwix.downloadbar14-progress"];

		NSString *bulletinUUID = [[NSUUID UUID] UUIDString];

		[bulletin setSection:@"com.apple.Preferences"];
		[bulletin setSectionID:@"com.apple.Preferences"];

		[bulletin setBulletinID:bulletinUUID];
		[bulletin setRecordID:bulletinUUID];
		[bulletin setThreadID:self.bundleIdentifier];
		[bulletin setPublisherBulletinID:[NSString stringWithFormat:@"com.miwix.downloadbar14/%@", self.bundleIdentifier]];
		[bulletin setDate:[NSDate date]];
		[bulletin setLockScreenPriority:1];

		@try {
			NSString *appInfoUrl = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@", self.bundleIdentifier];

			NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:appInfoUrl]];

			NSError *e = nil;
			NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error: &e];

			NSString *trackViewUrl = [[[jsonDict objectForKey:@"results"] objectAtIndex:0] objectForKey:@"trackViewUrl"];

			BBAction *defaultAction = [BBAction actionWithLaunchURL:[NSURL URLWithString:trackViewUrl]];
			[defaultAction setCanBypassPinLock:YES];
			[defaultAction setShouldDismissBulletin:NO];
			[bulletin setDefaultAction:defaultAction];

			NSMutableDictionary *supplementaryActions = [NSMutableDictionary new];
			NSMutableArray *supplementaryActionsArray = [NSMutableArray new];

			BBAction *prioritizeAction = [BBAction actionWithIdentifier:@"prioritize_app_action" title:@"Prioritize"];
			[prioritizeAction setActionType:2];
			[prioritizeAction setCanBypassPinLock:YES];
			[prioritizeAction setShouldDismissBulletin:NO];
			[supplementaryActionsArray addObject:prioritizeAction];

			BBAction *pauseAction = [BBAction actionWithIdentifier:@"pause_app_action" title:@"Pause"];
			[pauseAction setActionType:2];
			[pauseAction setCanBypassPinLock:YES];
			[pauseAction setShouldDismissBulletin:NO];
			[supplementaryActionsArray addObject:pauseAction];

			BBAction *cancelAction = [BBAction actionWithIdentifier:@"cancel_app_action" title:@"Cancel"];
			[cancelAction setActionType:2];
			[cancelAction setCanBypassPinLock:YES];
			[cancelAction setShouldDismissBulletin:YES];
			[supplementaryActionsArray addObject:cancelAction];

			[supplementaryActions setObject:supplementaryActionsArray forKey:@(0)];
			[bulletin setSupplementaryActionsByLayout:supplementaryActions];
		}
		@catch (NSException *x) {
			NSLog(@"[DownloadBar] %@", x);
		}

		bulletinDictionary[self.bundleIdentifier] = bulletin;

		dispatch_async(__BBServerQueue, ^{
			[sharedServer publishBulletin:bulletin destinations:4];
		});
	}
}

%new
-(void)installsFinished:(NSNotification*)notification{
	NSArray<NSString*> *identifiers = notification.userInfo[@"identifiers"];

	if([identifiers containsObject:self.bundleIdentifier]){
		if([self.progress isKindOfClass:%c(FBSApplicationPlaceholderProgress)]) ((FBSApplicationPlaceholderProgress*)self.progress).installEndedDate = NSDate.date;

		BBBulletin *bulletin = [[BBBulletin alloc] init];
		[bulletin setHeader:self.displayName];
		[bulletin setTitle:[NSString stringWithFormat:@"%@ Installed", self.displayName]];
		[bulletin setMessage:@"Tap to open"];

		NSString *bulletinUUID = [[NSUUID UUID] UUIDString];
		@try {
			bulletinUUID = bulletinDictionary[self.bundleIdentifier].bulletinID;
		}
		@catch (NSException *x) {
			NSLog(@"[DownloadBar] %@", x);
		}

		dispatch_async(__BBServerQueue, ^{
			[sharedServer _clearBulletinIDs:@[bulletinUUID] forSectionID:bulletin.sectionID shouldSync:YES];
		});

		[bulletin setSection:@"com.apple.Preferences"];
		[bulletin setSectionID:@"com.apple.Preferences"];

		[bulletin setBulletinID:bulletinUUID];
		[bulletin setRecordID:bulletinUUID];
		[bulletin setThreadID:self.bundleIdentifier];
		[bulletin setPublisherBulletinID:[NSString stringWithFormat:@"com.miwix.downloadbar14-completed/%@", self.bundleIdentifier]];
		[bulletin setDate:[NSDate date]];
		[bulletin setLockScreenPriority:1];

		BBAction *defaultAction = [BBAction actionWithLaunchBundleID:self.bundleIdentifier];
		[defaultAction setCanBypassPinLock:YES];
		[defaultAction setShouldDismissBulletin:YES];
		[bulletin setDefaultAction:defaultAction];

		dispatch_async(__BBServerQueue, ^{
			[sharedServer publishBulletin:bulletin destinations:14];
		});

		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"installsStarted" object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"installsFinished" object:nil];
	}
}
%end

@interface NCNotificationRequest : NSObject
@property BBBulletin *bulletin;
@property (nonatomic,copy,readonly) NSString * threadIdentifier;
@end

@interface NCNotificationAction : NSObject
@property (nonatomic,copy,readonly) NSString * identifier;
@property (nonatomic,copy,readonly) NSString * name;
@end

%hook CSNotificationDispatcher
-(void)destination:(id)arg1 performAction:(id)arg2 forNotificationRequest:(id)arg3 requestAuthentication:(BOOL)arg4 withParameters:(id)arg5 completion:(/*^block*/id)arg6 {
	NCNotificationAction *action = arg2;
	NCNotificationRequest *req = arg3;
	FBSApplicationPlaceholderProgress *prog = progressDictionary[req.threadIdentifier];
	if ([action.identifier isEqualToString:@"prioritize_app_action"]) {
		[prog.placeholder prioritize];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"dismissLongLook" object:nil userInfo:@{@"identifiers": @[[req.bulletin.publisherBulletinID substringFromIndex:[req.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]]}];
	} else if ([action.identifier isEqualToString:@"pause_app_action"]) {
		[prog.placeholder pause];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"dismissLongLook" object:nil userInfo:@{@"identifiers": @[[req.bulletin.publisherBulletinID substringFromIndex:[req.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]]}];
	} else if ([action.identifier isEqualToString:@"resume_app_action"]) {
		[prog.placeholder resume];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"dismissLongLook" object:nil userInfo:@{@"identifiers": @[[req.bulletin.publisherBulletinID substringFromIndex:[req.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]]}];
	} else if ([action.identifier isEqualToString:@"cancel_app_action"]) {
		[prog.placeholder cancel];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"dismissLongLook" object:nil userInfo:@{@"identifiers": @[[req.bulletin.publisherBulletinID substringFromIndex:[req.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]]}];
	} else {
		%orig;
	}
}
%end

%hook FBSApplicationLibrary
-(void)applicationInstallsDidStart:(id)installs{
	%orig;

	NSMutableArray<NSString*> *identifiers = [[NSMutableArray alloc] init];
	for(LSApplicationProxy *proxy in installs){
		[identifiers addObject:proxy.applicationIdentifier];
	}

	[[NSNotificationCenter defaultCenter] postNotificationName:@"installsStarted" object:nil userInfo:@{@"identifiers": identifiers}];
}

-(void)applicationsDidInstall:(id)applications{
	%orig;

	NSMutableArray<NSString*> *identifiers = [[NSMutableArray alloc] init];
	for(LSApplicationProxy *proxy in applications){
		[identifiers addObject:proxy.applicationIdentifier];
	}

	[[NSNotificationCenter defaultCenter] postNotificationName:@"installsFinished" object:nil userInfo:@{@"identifiers": identifiers}];
}
%end

#pragma mark Handling Bulletin App Icon

@interface UIImage()
+(instancetype)_applicationIconImageForBundleIdentifier:(NSString*)bundleId format:(int)format;
@end

%hook BBBulletin
-(BBSectionIcon *)sectionIcon{
	if ([self.publisherBulletinID hasPrefix:@"com.miwix.downloadbar14/"] || [self.publisherBulletinID hasPrefix:@"com.miwix.downloadbar14-completed/"]) {
		UIImage *img = [UIImage _applicationIconImageForBundleIdentifier:[self.publisherBulletinID substringFromIndex:[self.publisherBulletinID rangeOfString:@"/"].location + 1] format:1];

		BBSectionIconVariant *variant = [[BBSectionIconVariant alloc] init];
		[variant setImageData:UIImagePNGRepresentation(img)];

		BBSectionIcon *icon = [[BBSectionIcon alloc] init];
		[icon addVariant:variant];

		return icon;
	} else return %orig;
}

-(BOOL)allowsAutomaticRemovalFromLockScreen{
	if ([self.publisherBulletinID hasPrefix:@"com.miwix.downloadbar14/"] || [self.publisherBulletinID hasPrefix:@"com.miwix.downloadbar14-completed/"]) {
		return false;
	}

	return %orig;
}
%end

#pragma mark Handling Notification Content

@interface PLPlatterView : UIView
@end

@interface NCNotificationViewControllerView : UIView
@property PLPlatterView *contentView;
@end

@interface NCNotificationContentView : UIView
@property(getter=_primaryLabel,nonatomic,readonly) UILabel *primaryLabel;
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
@property(nonatomic, strong) UIView *progressContainerView;
@property(nonatomic, strong) UILabel *progressLabel;
@property(nonatomic, strong) NSTimer *progressUpdateTimer;
-(BOOL)dismissPresentedViewControllerAndClearNotification:(BOOL)clear animated:(BOOL)animated;
-(void)updateProgressLabel:(NSTimer*)timer;
-(void)setupContent;
-(void)resetContent;
@end

@interface NCNotificationShortLookViewController : NCNotificationViewController
@end

@interface NCNotificationLongLookViewController : NCNotificationViewController
@end

%hook NCNotificationShortLookViewController
%property(nonatomic, strong) UIProgressView *progressView;
%property(nonatomic, strong) UIView *progressContainerView;
%property(nonatomic, strong) UILabel *progressLabel;
%property(nonatomic, strong) NSTimer *progressUpdateTimer;

-(void)viewWillAppear:(BOOL)animated{
	%orig;

	if ([self.notificationRequest.bulletin.publisherBulletinID hasPrefix:@"com.miwix.downloadbar14/"]) {
		[self setupContent];
	}
}

-(void)viewWillDisappear:(BOOL)animated{
	%orig;

	if(self.progressUpdateTimer){
		[self.progressUpdateTimer invalidate];
		self.progressUpdateTimer = NULL;
	}
}

%new
-(void)updateProgressLabel:(NSTimer*)timer{
	if(progressDictionary[[self.notificationRequest.bulletin.publisherBulletinID substringFromIndex:[self.notificationRequest.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]].pauseDate) {
		progressDictionary[[self.notificationRequest.bulletin.publisherBulletinID substringFromIndex:[self.notificationRequest.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]].pausedDuration = @(progressDictionary[[self.notificationRequest.bulletin.publisherBulletinID substringFromIndex:[self.notificationRequest.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]].pausedDuration.doubleValue + -progressDictionary[[self.notificationRequest.bulletin.publisherBulletinID substringFromIndex:[self.notificationRequest.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]].pauseDate.timeIntervalSinceNow);
		progressDictionary[[self.notificationRequest.bulletin.publisherBulletinID substringFromIndex:[self.notificationRequest.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]].pauseDate = NSDate.date;
	}

	double pausedDuration = progressDictionary[[self.notificationRequest.bulletin.publisherBulletinID substringFromIndex:[self.notificationRequest.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]].pausedDuration.doubleValue;
	BOOL paused = progressDictionary[[self.notificationRequest.bulletin.publisherBulletinID substringFromIndex:[self.notificationRequest.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]].placeholder.resumable && !progressDictionary[[self.notificationRequest.bulletin.publisherBulletinID substringFromIndex:[self.notificationRequest.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]].placeholder.pausable;

	long total = (long)floor(-[progressDictionary[[self.notificationRequest.bulletin.publisherBulletinID substringFromIndex:[self.notificationRequest.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]].installStartedDate timeIntervalSinceDate:[NSDate.date earlierDate:progressDictionary[[self.notificationRequest.bulletin.publisherBulletinID substringFromIndex:[self.notificationRequest.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]].installEndedDate]] - pausedDuration);
	
	int seconds = total % 60;
	int minutes = total / 60 % 60;
	int hours = total / 60 / 60;

	NSString *timeElapsed = [NSString stringWithFormat:@"Time elapsed: %@%@%@", hours > 0 ? [NSString stringWithFormat:@"%d%@ ", hours, @"h"] : @"", minutes > 0 ? [NSString stringWithFormat:@"%d%@ ", minutes, @"m"] : @"", (seconds > 0 || (minutes == 0 && hours == 0)) ? [NSString stringWithFormat:@"%d%@ ", seconds, @"s"] : @""];
	if([timeElapsed hasSuffix:@" "]) timeElapsed = [timeElapsed substringToIndex:timeElapsed.length - 1];

	/*total = (long)floor(MSHookIvar<NSProgress*>(progressDictionary[[self.notificationRequest.bulletin.publisherBulletinID substringFromIndex:[self.notificationRequest.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]], "_progress").estimatedTimeRemaining.longValue);
	
	seconds = total % 60;
	minutes = total / 60 % 60;
	hours = total / 60 / 60;

	NSString *timeRemaining = [NSString stringWithFormat:@"Remaining: %@%@%@", hours > 0 ? [NSString stringWithFormat:@"%d%@ ", hours, @"h"] : @"", minutes > 0 ? [NSString stringWithFormat:@"%d%@ ", minutes, @"m"] : @"", (seconds > 0 || (minutes == 0 && hours == 0)) ? [NSString stringWithFormat:@"%d%@ ", seconds, @"s"] : @""];
	if([timeRemaining hasSuffix:@" "]) timeRemaining = [timeRemaining substringToIndex:timeRemaining.length - 1];*/

	self.progressLabel.text = [NSString stringWithFormat:@"%@%@%@", timeElapsed, self.progressView.progress >= 1 || paused ? @" - " : @"", self.progressView.progress >= 1 ? @"Finished" : (paused ? @"Paused" : @"")];

	if(self.progressView.progress >= 1){
		[self.progressUpdateTimer invalidate];
		self.progressUpdateTimer = NULL;
	}
}

%new
-(void)setupContent{
	if(!self.progressView) {
		self.progressContainerView = [[UIView alloc] init];
		self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
		[self.progressContainerView addSubview:self.progressView];

		self.progressLabel = [[UILabel alloc] init];
	}
	
	self.progressView.observedProgress = MSHookIvar<NSProgress*>(progressDictionary[[self.notificationRequest.bulletin.publisherBulletinID substringFromIndex:[self.notificationRequest.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]], "_progress");
	if(self.progressView.observedProgress == nil) self.progressView.progress = 1;

	NCNotificationContentView *content = ((NCNotificationShortLookView*)((NCNotificationViewControllerView*)self.view).contentView).notificationContentView;
	UILabel *label = content.secondaryLabel;
	label.hidden = true;
	
	self.progressView.translatesAutoresizingMaskIntoConstraints = false;
	
	self.progressView.progressTintColor = [UIColor systemBlueColor];
	self.progressView.trackTintColor = [UIColor lightGrayColor];
	
	[self.progressContainerView removeFromSuperview];
	[content addSubview:self.progressContainerView];
	self.progressContainerView.translatesAutoresizingMaskIntoConstraints = false;

	if(!label) return;
	
	[self.progressContainerView.topAnchor constraintEqualToAnchor:label.topAnchor].active = true;
	[self.progressContainerView.bottomAnchor constraintEqualToAnchor:label.centerYAnchor].active = true;
	[self.progressContainerView.leadingAnchor constraintEqualToAnchor:label.leadingAnchor].active = true;
	[self.progressContainerView.trailingAnchor constraintEqualToAnchor:label.trailingAnchor].active = true;

	[self.progressView.centerYAnchor constraintEqualToAnchor:self.progressContainerView.centerYAnchor].active = true;
	[self.progressView.leadingAnchor constraintEqualToAnchor:self.progressContainerView.leadingAnchor].active = true;
	[self.progressView.trailingAnchor constraintEqualToAnchor:self.progressContainerView.trailingAnchor].active = true;

	[self.progressLabel removeFromSuperview];
	self.progressLabel.translatesAutoresizingMaskIntoConstraints = false;
	[content addSubview:self.progressLabel];
	self.progressLabel.textColor = UIColor.grayColor;

	[self.progressLabel.topAnchor constraintEqualToAnchor:label.centerYAnchor].active = true;
	[self.progressLabel.bottomAnchor constraintEqualToAnchor:label.bottomAnchor].active = true;
	[self.progressLabel.leadingAnchor constraintEqualToAnchor:label.leadingAnchor].active = true;
	[self.progressLabel.trailingAnchor constraintEqualToAnchor:label.trailingAnchor].active = true;

	[self updateProgressLabel:NULL];

	if(self.progressUpdateTimer && self.progressView.progress < 1){
		[self.progressUpdateTimer invalidate];
		self.progressUpdateTimer = NULL;
	}

	self.progressUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateProgressLabel:) userInfo:nil repeats:YES];
}

%new
-(void)resetContent{
	[self.progressContainerView removeFromSuperview];
	[self.progressLabel removeFromSuperview];
	((NCNotificationShortLookView*)((NCNotificationViewControllerView*)self.view).contentView).notificationContentView.secondaryLabel.hidden = false;
}
%end

%hook NCNotificationLongLookViewController
%property(nonatomic, strong) UIProgressView *progressView;
%property(nonatomic, strong) UIView *progressContainerView;
%property(nonatomic, strong) UILabel *progressLabel;
%property(nonatomic, strong) NSTimer *progressUpdateTimer;

-(void)viewDidLoad{
	%orig;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissWithNotification:) name:@"dismissLongLook" object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
	%orig;

	if ([self.notificationRequest.bulletin.publisherBulletinID hasPrefix:@"com.miwix.downloadbar14/"]) {
		[self setupContent];
	}
}

-(void)viewWillDisappear:(BOOL)animated{
	%orig;

	if(self.progressUpdateTimer){
		[self.progressUpdateTimer invalidate];
		self.progressUpdateTimer = NULL;
	}
}

%new
-(void)dismissWithNotification:(NSNotification*)notification{
	if([notification.userInfo[@"identifiers"] containsObject:[self.notificationRequest.bulletin.publisherBulletinID substringFromIndex:[self.notificationRequest.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]]){
		[self dismissPresentedViewControllerAndClearNotification:false animated:true];
	}
}

%new
-(void)updateProgressLabel:(NSTimer*)timer{
	if(progressDictionary[[self.notificationRequest.bulletin.publisherBulletinID substringFromIndex:[self.notificationRequest.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]].pauseDate) {
		progressDictionary[[self.notificationRequest.bulletin.publisherBulletinID substringFromIndex:[self.notificationRequest.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]].pausedDuration = @(progressDictionary[[self.notificationRequest.bulletin.publisherBulletinID substringFromIndex:[self.notificationRequest.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]].pausedDuration.doubleValue + -progressDictionary[[self.notificationRequest.bulletin.publisherBulletinID substringFromIndex:[self.notificationRequest.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]].pauseDate.timeIntervalSinceNow);
		progressDictionary[[self.notificationRequest.bulletin.publisherBulletinID substringFromIndex:[self.notificationRequest.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]].pauseDate = NSDate.date;
	}

	double pausedDuration = progressDictionary[[self.notificationRequest.bulletin.publisherBulletinID substringFromIndex:[self.notificationRequest.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]].pausedDuration.doubleValue;
	BOOL paused = progressDictionary[[self.notificationRequest.bulletin.publisherBulletinID substringFromIndex:[self.notificationRequest.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]].placeholder.resumable && !progressDictionary[[self.notificationRequest.bulletin.publisherBulletinID substringFromIndex:[self.notificationRequest.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]].placeholder.pausable;

	long total = (long)floor(-[progressDictionary[[self.notificationRequest.bulletin.publisherBulletinID substringFromIndex:[self.notificationRequest.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]].installStartedDate timeIntervalSinceDate:[NSDate.date earlierDate:progressDictionary[[self.notificationRequest.bulletin.publisherBulletinID substringFromIndex:[self.notificationRequest.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]].installEndedDate]] - pausedDuration);
	
	int seconds = total % 60;
	int minutes = total / 60 % 60;
	int hours = total / 60 / 60;

	NSString *timeElapsed = [NSString stringWithFormat:@"Time elapsed: %@%@%@", hours > 0 ? [NSString stringWithFormat:@"%d%@ ", hours, @"h"] : @"", minutes > 0 ? [NSString stringWithFormat:@"%d%@ ", minutes, @"m"] : @"", (seconds > 0 || (minutes == 0 && hours == 0)) ? [NSString stringWithFormat:@"%d%@ ", seconds, @"s"] : @""];
	if([timeElapsed hasSuffix:@" "]) timeElapsed = [timeElapsed substringToIndex:timeElapsed.length - 1];

	/*total = (long)floor(MSHookIvar<NSProgress*>(progressDictionary[[self.notificationRequest.bulletin.publisherBulletinID substringFromIndex:[self.notificationRequest.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]], "_progress").estimatedTimeRemaining.longValue);
	
	seconds = total % 60;
	minutes = total / 60 % 60;
	hours = total / 60 / 60;

	NSString *timeRemaining = [NSString stringWithFormat:@"Remaining: %@%@%@", hours > 0 ? [NSString stringWithFormat:@"%d%@ ", hours, @"h"] : @"", minutes > 0 ? [NSString stringWithFormat:@"%d%@ ", minutes, @"m"] : @"", (seconds > 0 || (minutes == 0 && hours == 0)) ? [NSString stringWithFormat:@"%d%@ ", seconds, @"s"] : @""];
	if([timeRemaining hasSuffix:@" "]) timeRemaining = [timeRemaining substringToIndex:timeRemaining.length - 1];*/

	self.progressLabel.text = [NSString stringWithFormat:@"%@%@%@", timeElapsed, self.progressView.progress >= 1 || paused ? @" - " : @"", self.progressView.progress >= 1 ? @"Finished" : (paused ? @"Paused" : @"")];

	if(self.progressView.progress >= 1){
		[self.progressUpdateTimer invalidate];
		self.progressUpdateTimer = NULL;
	}
}

%new
-(void)setupContent{
	if(!self.progressView) {
		self.progressContainerView = [[UIView alloc] init];
		self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
		[self.progressContainerView addSubview:self.progressView];

		self.progressLabel = [[UILabel alloc] init];
	}
	
	self.progressView.observedProgress = MSHookIvar<NSProgress*>(progressDictionary[[self.notificationRequest.bulletin.publisherBulletinID substringFromIndex:[self.notificationRequest.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]], "_progress");
	if(self.progressView.observedProgress == nil) self.progressView.progress = 1;

	NCNotificationContentView *content = MSHookIvar<NCNotificationContentView*>(MSHookIvar<NCNotificationLongLookView*>(self, "_lookView"), "_notificationContentView");
	UITextView *label = content.secondaryTextView;
	label.hidden = true;
	
	self.progressView.translatesAutoresizingMaskIntoConstraints = false;
	
	self.progressView.progressTintColor = [UIColor systemBlueColor];
	self.progressView.trackTintColor = [UIColor lightGrayColor];
	
	[self.progressContainerView removeFromSuperview];
	[content addSubview:self.progressContainerView];
	self.progressContainerView.translatesAutoresizingMaskIntoConstraints = false;

	[self.progressContainerView.topAnchor constraintEqualToAnchor:content.primaryLabel.bottomAnchor].active = true;
	[self.progressContainerView.heightAnchor constraintEqualToAnchor:content.primaryLabel.heightAnchor].active = true;
	[self.progressContainerView.leadingAnchor constraintEqualToAnchor:label.leadingAnchor].active = true;
	[self.progressContainerView.trailingAnchor constraintEqualToAnchor:label.trailingAnchor].active = true;

	[self.progressView.centerYAnchor constraintEqualToAnchor:self.progressContainerView.centerYAnchor].active = true;
	[self.progressView.leadingAnchor constraintEqualToAnchor:self.progressContainerView.leadingAnchor].active = true;
	[self.progressView.trailingAnchor constraintEqualToAnchor:self.progressContainerView.trailingAnchor].active = true;

	[self.progressLabel removeFromSuperview];
	self.progressLabel.translatesAutoresizingMaskIntoConstraints = false;
	[content addSubview:self.progressLabel];
	self.progressLabel.textColor = UIColor.grayColor;

	[self.progressLabel.topAnchor constraintEqualToAnchor:self.progressContainerView.bottomAnchor].active = true;
	[self.progressLabel.heightAnchor constraintEqualToAnchor:content.primaryLabel.heightAnchor].active = true;
	[self.progressLabel.leadingAnchor constraintEqualToAnchor:label.leadingAnchor].active = true;
	[self.progressLabel.trailingAnchor constraintEqualToAnchor:label.trailingAnchor].active = true;

	[self updateProgressLabel:NULL];

	if(self.progressUpdateTimer && self.progressView.progress < 1){
		[self.progressUpdateTimer invalidate];
		self.progressUpdateTimer = NULL;
	}

	self.progressUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateProgressLabel:) userInfo:nil repeats:YES];
}

%new
-(void)resetContent{
	[self.progressContainerView removeFromSuperview];
	[self.progressLabel removeFromSuperview];
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
		[self.contentViewController setupContent];
	} else{
		[self.contentViewController resetContent];
	}
}

-(void)didMoveToWindow{
	%orig;

	if([self.contentViewController.notificationRequest.bulletin.publisherBulletinID hasPrefix:@"com.miwix.downloadbar14/"]) {
		[self.contentViewController setupContent];
	} else{
		[self.contentViewController resetContent];
	}
}
%end