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
@property (assign,nonatomic) BOOL ignoresDowntime;
@property (assign,nonatomic) BOOL ignoresQuietMode;
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
@property (nonatomic,readonly) NSString * bundleIdentifier;
@property (nonatomic,readonly) NSString * displayName;
@end

@interface SBApplicationController : NSObject {
	NSMutableDictionary* _applicationsByBundleIdentifer;
}
+(id)sharedInstance;
-(id)applicationWithBundleIdentifier:(id)arg1 ;
-(void)uninstallApplication:(id)arg1 ;
@end

@interface SBIconProgressView : UIView
@property (nonatomic, strong) UILabel *additionalLabel;
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

static NSMutableDictionary<NSString*, id> *progressDictionary;
static NSMutableDictionary<NSString*, BBBulletin*> *bulletinDictionary;
static BOOL readdedNotifications = false;

%hook SBIconProgressView
%property (nonatomic, strong) UILabel *additionalLabel;
%property (nonatomic, strong) UIView *progressBar;
%property (nonatomic, strong) UIView *progressBarBackground;
%property (nonatomic, retain) NSString *bundleId;
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

		self.additionalLabel = [[UILabel alloc] init];
		self.additionalLabel.translatesAutoresizingMaskIntoConstraints = false;
		self.additionalLabel.font = [UIFont boldSystemFontOfSize:10];
		self.additionalLabel.textAlignment = NSTextAlignmentCenter;
		self.additionalLabel.text = @"0%%";

		[self addSubview: self.progressBarBackground];
		[self addSubview: self.progressBar];
		[self addSubview: self.additionalLabel];

		[self setupSubviews];
	}
	return self;
}

-(void)setDisplayedFraction:(double)arg1 {
	%orig;
	self.additionalLabel.text = [NSString stringWithFormat:@"%i%%", (int)(arg1 * 100)];
	self.additionalLabel.textColor = [UIColor whiteColor];
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

	[self.additionalLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = true;
	[self.additionalLabel.bottomAnchor constraintEqualToAnchor:self.progressBarBackground.topAnchor constant:-2].active = true;
}
%end

#pragma mark Handling App Installation Queues, Posting Push Notifications

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
@property() NSNumber *shouldRecallOnceProgressIsSet;
-(void)prioritize;
-(void)pause;
-(void)_pauseWithResult:(id)result;
-(void)resume;
-(void)cancel;
-(void)installsStarted:(NSNotification*)notification;
@end

@interface FBSApplicationPlaceholderProgress : NSObject <FBSApplicationPlaceholderProgress>
@property FBSApplicationPlaceholder *placeholder;
@end

@interface SBLockScreenManager : NSObject
-(void)lockScreenViewControllerRequestsUnlock;
-(BOOL)isUILocked;
+(instancetype)sharedInstanceIfExists;
@end

@interface FBSApplicationLibrary : NSObject
-(NSArray*)allPlaceholders;
@end

%hook FBSApplicationLibrary
-(void)_load{
	%orig;

	if(!readdedNotifications){
		readdedNotifications = true;

		dispatch_async(dispatch_get_main_queue(), ^{
			NSMutableArray *active = ((NSArray*)[NSUserDefaults.standardUserDefaults objectForKey:@"com.miwix.downloadbar14/active"]).mutableCopy;
			NSMutableArray *activeApps = active.mutableCopy;
			if(!active) active = [[NSMutableArray alloc] init];

			NSMutableArray *finished = ((NSArray*)[NSUserDefaults.standardUserDefaults objectForKey:@"com.miwix.downloadbar14/finished"]).mutableCopy;
			if(!finished) finished = [[NSMutableArray alloc] init];

			for(FBSApplicationPlaceholder *placeholder in [self allPlaceholders]) {
				[placeholder installsStarted:NULL];
				[activeApps removeObject:placeholder.bundleIdentifier];
			}

			for(NSString *identifier in activeApps) {
				[active removeObject:identifier];
				[finished addObject:identifier];
			}

			for(NSString *identifier in finished){
				SBApplication *app = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:identifier];

				__block BBBulletin *bulletin = [[BBBulletin alloc] init];
				[bulletin setHeader:app.displayName];
				[bulletin setTitle:[NSString stringWithFormat:@"%@ Installed", app.displayName]];
				[bulletin setMessage:@"Tap to open"];

				NSString *bulletinUUID = [[NSUUID UUID] UUIDString];
				@try {
					bulletinUUID = bulletinDictionary[app.bundleIdentifier].bulletinID;
				}
				@catch (NSException *x) {
					NSLog(@"[DownloadBar] %@", x);
				}

				if(bulletinUUID) dispatch_async(__BBServerQueue, ^{
					[sharedServer _clearBulletinIDs:@[bulletinUUID] forSectionID:bulletin.sectionID shouldSync:YES];
				});
				else bulletinUUID = [[NSUUID UUID] UUIDString];

				[bulletin setSection:@"com.apple.Preferences"];
				[bulletin setSectionID:@"com.apple.Preferences"];

				[bulletin setBulletinID:bulletinUUID];
				[bulletin setRecordID:bulletinUUID];
				[bulletin setThreadID:app.bundleIdentifier];
				[bulletin setPublisherBulletinID:[NSString stringWithFormat:@"com.miwix.downloadbar14-completed/%@", app.bundleIdentifier]];
				[bulletin setDate:[NSDate date]];
				[bulletin setLockScreenPriority:1];

				BBAction *defaultAction = [BBAction actionWithLaunchBundleID:app.bundleIdentifier];
				[defaultAction setCanBypassPinLock:YES];
				[defaultAction setShouldDismissBulletin:YES];
				[bulletin setDefaultAction:defaultAction];

				[bulletin setIgnoresDowntime:YES];
				[bulletin setIgnoresQuietMode:YES];

				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), __BBServerQueue, ^{
					[sharedServer publishBulletin:bulletin destinations:14];
				});
			}

			[NSUserDefaults.standardUserDefaults setObject:active forKey:@"com.miwix.downloadbar14/active"];
			[NSUserDefaults.standardUserDefaults setObject:finished forKey:@"com.miwix.downloadbar14/finished"];
			[NSUserDefaults.standardUserDefaults synchronize];
		});
	}
}
%end

@interface BBResponse : NSObject
-(void)setSendBlock:(id)arg1 ;
@end

%hook FBSApplicationPlaceholder
%property(nonatomic, retain) NSNumber *shouldRecallOnceProgressIsSet;

-(instancetype)_initWithApplicationProxy:(id)proxy{
	FBSApplicationPlaceholder *instance = %orig;

    [self addObserver:instance forKeyPath:@"prioritizable" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:instance forKeyPath:@"pausable" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:instance forKeyPath:@"cancellable" options:NSKeyValueObservingOptionNew context:nil];
	[[NSNotificationCenter defaultCenter] addObserver:instance selector:@selector(installsStarted:) name:@"installsStarted" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:instance selector:@selector(installsFinished:) name:@"installsFinished" object:nil];

	return instance;
}

%new
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	BOOL newKey = [change objectForKey:NSKeyValueChangeNewKey];
	if (!newKey) {
		NSArray<NSString*> *identifiersToRemove;
		if ([keyPath isEqualToString:@"prioritizable"]) identifiersToRemove = @[@"prioritize_app_action"];
		else if ([keyPath isEqualToString:@"pausable"]) identifiersToRemove = @[@"pause_app_action", @"resume_app_action"];
		else if ([keyPath isEqualToString:@"cancellable"]) identifiersToRemove = @[@"cancel_app_action"];

		BBBulletin *bulletin = bulletinDictionary[self.bundleIdentifier];
		if(!bulletin) return;

		NSMutableArray *actionsArray = bulletin.supplementaryActionsByLayout[@(0)];
		BBAction *entryToRemove;
		for (NSString *iden in identifiersToRemove) {
			for (BBAction *entry in actionsArray) {
				if ([entry.identifier isEqualToString:iden])
					entryToRemove = entry;
			}
			@try {
				[actionsArray removeObject:entryToRemove];
			}
			@catch (NSException *x) {}
		}

		[bulletin setTitle:@"Installing"];

		dispatch_async(__BBServerQueue, ^{
			[sharedServer publishBulletin:bulletin destinations:4];
		});
	}
}

-(void)_prioritizeWithResult:(id)result{
	if(self.resumable) [self resume];

	%orig;
}

-(void)_pauseWithResult:(id)result{
	%orig;

	BBBulletin *bulletin = bulletinDictionary[self.bundleIdentifier];
	if(!bulletin) return;

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

	[bulletin setTitle:@"Download paused"];

	dispatch_async(__BBServerQueue, ^{
		[sharedServer publishBulletin:bulletin destinations:4];
	});
}

-(void)_resumeWithResult:(id)result{
	%orig;

	BBBulletin *bulletin = bulletinDictionary[self.bundleIdentifier];
	if(!bulletin) return;

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

	[bulletin setTitle:@"Downloading"];

	dispatch_async(__BBServerQueue, ^{
		[sharedServer publishBulletin:bulletin destinations:4];
	});
}

-(void)_cancelWithResult:(id)result{
	%orig;

	NSString *bulletinUUID = bulletinDictionary[self.bundleIdentifier].bulletinID;
	if(!bulletinUUID) return;

	dispatch_async(__BBServerQueue, ^{
		[sharedServer _clearBulletinIDs:@[bulletinUUID] forSectionID:bulletinUUID shouldSync:YES];
	});
}

-(void)_reloadProgress{
	%orig;

	if(self.shouldRecallOnceProgressIsSet && [self.shouldRecallOnceProgressIsSet boolValue]){
		[self installsStarted:NULL];
		self.shouldRecallOnceProgressIsSet = @false;
	}
}

%new
-(void)installsStarted:(NSNotification*)notification{
	NSArray<NSString*> *identifiers = notification.userInfo[@"identifiers"];

	if(([identifiers containsObject:self.bundleIdentifier] || !notification) && [self.progress isKindOfClass:[%c(FBSApplicationPlaceholderProgress) class]]){
		if(!progressDictionary) progressDictionary = [[NSMutableDictionary alloc] init];
		if(!bulletinDictionary) bulletinDictionary = [[NSMutableDictionary alloc] init];

		NSMutableArray *active = ((NSArray*)[NSUserDefaults.standardUserDefaults objectForKey:@"com.miwix.downloadbar14/active"]).mutableCopy;
		if(!active) active = [[NSMutableArray alloc] init];
		[active removeObject:self.bundleIdentifier];
		[active addObject:self.bundleIdentifier];
		[NSUserDefaults.standardUserDefaults setObject:active forKey:@"com.miwix.downloadbar14/active"];
		[NSUserDefaults.standardUserDefaults synchronize];

		progressDictionary[self.bundleIdentifier] = (FBSApplicationPlaceholderProgress*)self.progress;
		BBBulletin *bulletin = [[BBBulletin alloc] init];
		[bulletin setHeader:self.displayName];
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

        [bulletin setIgnoresDowntime:YES];
        [bulletin setIgnoresQuietMode:YES];
		bulletinDictionary[self.bundleIdentifier] = bulletin;

		dispatch_sync(__BBServerQueue, ^{
			[sharedServer publishBulletin:bulletin destinations:4];
		});

		if(!self.pausable && self.resumable) [self _pauseWithResult:NULL];
	} else if(!notification){
		self.shouldRecallOnceProgressIsSet = @true;
	}
}

%new
-(void)installsFinished:(NSNotification*)notification{
	NSArray<NSString*> *identifiers = notification.userInfo[@"identifiers"];

	if([identifiers containsObject:self.bundleIdentifier]){
		NSMutableArray *active = ((NSArray*)[NSUserDefaults.standardUserDefaults objectForKey:@"com.miwix.downloadbar14/active"]).mutableCopy;
		[active removeObject:self.bundleIdentifier];
		[NSUserDefaults.standardUserDefaults setObject:active forKey:@"com.miwix.downloadbar14/active"];

		NSMutableArray *finished = ((NSArray*)[NSUserDefaults.standardUserDefaults objectForKey:@"com.miwix.downloadbar14/finished"]).mutableCopy;
		if(!finished) finished = [[NSMutableArray alloc] init];
		[finished removeObject:self.bundleIdentifier];
		[finished addObject:self.bundleIdentifier];
		[NSUserDefaults.standardUserDefaults setObject:finished forKey:@"com.miwix.downloadbar14/finished"];
		[NSUserDefaults.standardUserDefaults synchronize];

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

		if(bulletinUUID) dispatch_async(__BBServerQueue, ^{
			[sharedServer _clearBulletinIDs:@[bulletinUUID] forSectionID:bulletin.sectionID shouldSync:YES];
		});
		else bulletinUUID = [[NSUUID UUID] UUIDString];

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

		NSMutableDictionary *supplementaryActions = [NSMutableDictionary new];
		NSMutableArray *supplementaryActionsArray = [NSMutableArray new];

		BBAction *uninstallAction = [BBAction actionWithIdentifier:@"uninstall_app_action" title:@"Uninstall"];
		[uninstallAction setActionType:2];
		[uninstallAction setCanBypassPinLock:YES];
		[uninstallAction setShouldDismissBulletin:YES];
		[supplementaryActionsArray addObject:uninstallAction];

		[supplementaryActions setObject:supplementaryActionsArray forKey:@(0)];
		[bulletin setSupplementaryActionsByLayout:supplementaryActions];

        [bulletin setIgnoresDowntime:YES];
        [bulletin setIgnoresQuietMode:YES];

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
		NSString *bundleId = [req.bulletin.publisherBulletinID substringFromIndex:[req.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"exitLongLook" object:nil userInfo:@{@"identifiers": @[bundleId]}];
	} else if ([action.identifier isEqualToString:@"pause_app_action"]) {
		[prog.placeholder pause];
		NSString *bundleId = [req.bulletin.publisherBulletinID substringFromIndex:[req.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"exitLongLook" object:nil userInfo:@{@"identifiers": @[bundleId]}];
	} else if ([action.identifier isEqualToString:@"resume_app_action"]) {
		[prog.placeholder resume];
		NSString *bundleId = [req.bulletin.publisherBulletinID substringFromIndex:[req.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"exitLongLook" object:nil userInfo:@{@"identifiers": @[bundleId]}];
	} else if ([action.identifier isEqualToString:@"cancel_app_action"]) {
		[prog.placeholder cancel];
		NSString *bundleId = [req.bulletin.publisherBulletinID substringFromIndex:[req.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"dismissLongLook" object:nil userInfo:@{@"identifiers": @[bundleId]}];
	} else if ([action.identifier isEqualToString:@"uninstall_app_action"]) {
		SBApplicationController *controller = [%c(SBApplicationController) sharedInstance];
		NSString *bundleId = [req.bulletin.publisherBulletinID substringFromIndex:[req.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1];
		SBApplication *app = [controller applicationWithBundleIdentifier:bundleId];
		[controller uninstallApplication:app];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"dismissLongLook" object:nil userInfo:@{@"identifiers": @[bundleId]}];
		if(req.bulletin.bulletinID) dispatch_async(__BBServerQueue, ^{
			[sharedServer _clearBulletinIDs:@[req.bulletin.bulletinID] forSectionID:req.bulletin.sectionID shouldSync:YES];
		});
	} else {
		%orig;
	}

	if([req.bulletin.publisherBulletinID hasPrefix:@"com.miwix.downloadbar14-completed/"]){
		NSMutableArray *finished = ((NSArray*)[NSUserDefaults.standardUserDefaults objectForKey:@"com.miwix.downloadbar14/finished"]).mutableCopy;
		if(!finished) finished = [[NSMutableArray alloc] init];

		[finished removeObject:req.threadIdentifier];

		[NSUserDefaults.standardUserDefaults setObject:finished forKey:@"com.miwix.downloadbar14/finished"];
		[NSUserDefaults.standardUserDefaults synchronize];
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
@property(nonatomic, strong) UIProgressView *progressView;
@property(nonatomic, strong) UIView *progressContainerView;
@property(readonly) NSString *bundleId;
//@property(nonatomic, strong) UILabel *additionalLabel;
-(void)customContentRequestsDismiss:(id)content;
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
//%property(nonatomic, strong) UILabel *additionalLabel;

-(void)viewWillAppear:(BOOL)animated{
	%orig;

	if ([self.notificationRequest.bulletin.publisherBulletinID hasPrefix:@"com.miwix.downloadbar14/"]) {
		[self setupContent];
	}
}

%new
-(void)setupContent{
	if(!self.progressView) {
		self.progressContainerView = [[UIView alloc] init];
		self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
		[self.progressContainerView addSubview:self.progressView];

		//self.additionalLabel = [[UILabel alloc] init];
	}
	
	self.progressView.observedProgress = MSHookIvar<NSProgress*>(progressDictionary[[self.notificationRequest.bulletin.publisherBulletinID substringFromIndex:[self.notificationRequest.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]], "_progress");
	if(self.progressView.observedProgress == nil) self.progressView.progress = 1;

	NCNotificationContentView *content = ((NCNotificationShortLookView*)((NCNotificationViewControllerView*)self.view).contentView).notificationContentView;
	UILabel *label = content.secondaryLabel;
	label.hidden = true;
	
	self.progressView.translatesAutoresizingMaskIntoConstraints = false;
	
	self.progressView.progressTintColor = [UIColor systemBlueColor];
	self.progressView.trackTintColor = [UIColor lightGrayColor];
	
	if(!label) return;

	[self.progressContainerView removeFromSuperview];
	[content addSubview:self.progressContainerView];
	self.progressContainerView.translatesAutoresizingMaskIntoConstraints = false;
	
	[self.progressContainerView.topAnchor constraintEqualToAnchor:label.topAnchor].active = true;
	[self.progressContainerView.bottomAnchor constraintEqualToAnchor:label.bottomAnchor/*centerYAnchor*/].active = true;
	[self.progressContainerView.leadingAnchor constraintEqualToAnchor:label.leadingAnchor].active = true;
	[self.progressContainerView.trailingAnchor constraintEqualToAnchor:label.trailingAnchor].active = true;

	[self.progressView.centerYAnchor constraintEqualToAnchor:self.progressContainerView.centerYAnchor].active = true;
	[self.progressView.leadingAnchor constraintEqualToAnchor:self.progressContainerView.leadingAnchor].active = true;
	[self.progressView.trailingAnchor constraintEqualToAnchor:self.progressContainerView.trailingAnchor].active = true;

	/*[self.additionalLabel removeFromSuperview];
	self.additionalLabel.translatesAutoresizingMaskIntoConstraints = false;
	[content addSubview:self.additionalLabel];
	self.additionalLabel.textColor = UIColor.grayColor;*/

	/*[self.additionalLabel.topAnchor constraintEqualToAnchor:label.centerYAnchor].active = true;
	[self.additionalLabel.bottomAnchor constraintEqualToAnchor:label.bottomAnchor].active = true;
	[self.additionalLabel.leadingAnchor constraintEqualToAnchor:label.leadingAnchor].active = true;
	[self.additionalLabel.trailingAnchor constraintEqualToAnchor:label.trailingAnchor].active = true;*/
}

%new
-(void)resetContent{
	[self.progressContainerView removeFromSuperview];
	//[self.additionalLabel removeFromSuperview];
	((NCNotificationShortLookView*)((NCNotificationViewControllerView*)self.view).contentView).notificationContentView.secondaryLabel.hidden = false;
}
%end

%hook NCNotificationLongLookViewController
%property(nonatomic, strong) UIProgressView *progressView;
%property(nonatomic, strong) UIView *progressContainerView;
//%property(nonatomic, strong) UILabel *additionalLabel;

-(void)viewDidLoad{
	%orig;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitWithNotification:) name:@"exitLongLook" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissWithNotification:) name:@"dismissLongLook" object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
	%orig;

	if ([self.notificationRequest.bulletin.publisherBulletinID hasPrefix:@"com.miwix.downloadbar14/"]) {
		[self setupContent];
	}
}

%new
-(void)exitWithNotification:(NSNotification*)notification{
	if([notification.userInfo[@"identifiers"] containsObject:[NSString stringWithFormat:@"%@", [self.notificationRequest.bulletin.publisherBulletinID substringFromIndex:[self.notificationRequest.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]]]){
		[self customContentRequestsDismiss:NULL];
	}
}

%new
-(void)dismissWithNotification:(NSNotification*)notification{
	if([notification.userInfo[@"identifiers"] containsObject:[NSString stringWithFormat:@"%@", [self.notificationRequest.bulletin.publisherBulletinID substringFromIndex:[self.notificationRequest.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]]]){
		[self dismissViewControllerAnimated:YES completion:^{
			[bulletinDictionary removeObjectForKey:[NSString stringWithFormat:@"%@", [self.notificationRequest.bulletin.publisherBulletinID substringFromIndex:[self.notificationRequest.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]]];
		}];
	}
}

%new
-(void)setupContent{
	if(!self.progressView) {
		self.progressContainerView = [[UIView alloc] init];
		self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
		[self.progressContainerView addSubview:self.progressView];

		//self.additionalLabel = [[UILabel alloc] init];
	}
	
	self.progressView.observedProgress = MSHookIvar<NSProgress*>(progressDictionary[[NSString stringWithFormat:@"%@", [self.notificationRequest.bulletin.publisherBulletinID substringFromIndex:[self.notificationRequest.bulletin.publisherBulletinID rangeOfString:@"/"].location + 1]]], "_progress");
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

	/*[self.additionalLabel removeFromSuperview];
	self.additionalLabel.translatesAutoresizingMaskIntoConstraints = false;
	[content addSubview:self.additionalLabel];
	self.additionalLabel.textColor = UIColor.grayColor;*/

	/*[self.additionalLabel.topAnchor constraintEqualToAnchor:self.progressContainerView.bottomAnchor].active = true;
	[self.additionalLabel.heightAnchor constraintEqualToAnchor:content.primaryLabel.heightAnchor].active = true;
	[self.additionalLabel.leadingAnchor constraintEqualToAnchor:label.leadingAnchor].active = true;
	[self.additionalLabel.trailingAnchor constraintEqualToAnchor:label.trailingAnchor].active = true;*/
}

%new
-(void)resetContent{
	[self.progressContainerView removeFromSuperview];
	//[self.additionalLabel removeFromSuperview];
	MSHookIvar<NCNotificationContentView*>(MSHookIvar<NCNotificationLongLookView*>(self, "_lookView"), "_notificationContentView").secondaryTextView.hidden = false;
}
%end

@interface NCNotificationListCell : UIView
@property NCNotificationViewController *contentViewController;
@end

%hook NCNotificationListCell
-(void)_layoutContentView{
	%orig;

	if([self.contentViewController.notificationRequest.bulletin.publisherBulletinID hasPrefix:@"com.miwix.downloadbar14/"]) {
		[self.contentViewController setupContent];
	} else{
		[self.contentViewController resetContent];
	}
}

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
