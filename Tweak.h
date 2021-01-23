#pragma mark Public Frameworks
#import <UIKit/UIKit.h>

@interface UIImage(Private)
+(instancetype)_applicationIconImageForBundleIdentifier:(NSString*)bundleId format:(int)format;
@end

#pragma mark PlatterKit Framework

@interface PLPlatterView : UIView
@end

#pragma mark SpringBoard & SpringBoardHome Framework

@interface SBApplication : NSObject
@property (nonatomic,readonly) NSString *displayName;
@end

@interface SBApplicationController : NSObject
+(id)sharedInstance;
-(id)applicationWithBundleIdentifier:(id)arg1;
-(void)uninstallApplication:(id)arg1;
@end

@interface SBIconProgressView : UIView
@property (nonatomic, strong) UILabel *additionalLabel;
@property (nonatomic, strong) UIView *progressBar;
@property (nonatomic, strong) UIView *progressBarBackground;
-(void)setupSubviews;
@end

#pragma mark BulletinBoard Framework

@interface BBSectionIconVariant : NSObject
@property (nonatomic,copy) NSData *imageData;
@end

@interface BBSectionIcon : NSObject
-(void)addVariant:(BBSectionIconVariant *)arg1;
@end

@interface BBAction : NSObject
@property (nonatomic,copy) NSString *identifier;
@property (assign,nonatomic) long long actionType;
+(id)actionWithIdentifier:(id)arg1 title:(id)arg2;
+(id)actionWithLaunchURL:(id)arg1;
+(id)actionWithLaunchBundleID:(id)arg1;
-(void)setCanBypassPinLock:(BOOL)arg1;
-(void)setShouldDismissBulletin:(BOOL)arg1;
@end

@interface BBBulletin : NSObject
@property (assign,nonatomic) BOOL ignoresDowntime;
@property (assign,nonatomic) BOOL ignoresQuietMode;
@property (nonatomic,copy) BBAction *defaultAction; 
@property (nonatomic,retain) NSMutableDictionary *supplementaryActionsByLayout;
@property (nonatomic,copy) NSString *header;
@property (nonatomic,copy) NSString *section;
@property (nonatomic,copy) NSString *sectionID;
@property (nonatomic,copy) NSString *recordID;
@property (nonatomic,copy) NSString *publisherBulletinID;
@property (nonatomic,copy) NSString *threadID;
@property (nonatomic,copy) NSString *bulletinID;
@property (nonatomic,retain) NSDate *date;
@property (nonatomic,copy) NSString *message;
@property (nonatomic,copy) NSString *title;
-(void)setLockScreenPriority:(long long)arg1;
@end

@interface BBServer : NSObject
-(void)publishBulletin:(BBBulletin*)arg1 destinations:(unsigned long long)arg2;
-(void)_clearBulletinIDs:(id)arg1 forSectionID:(id)arg2 shouldSync:(BOOL)arg3;
@end

#pragma mark CoreServices Framework

@interface LSApplicationProxy : NSObject
@property(nonatomic, readonly, strong) NSString *applicationIdentifier;
@end

#pragma mark FrontBoardServices Framework

@protocol FBSApplicationPlaceholderProgress <NSObject>
@end

@interface FBSBundleInfo : NSObject
@property NSString *bundleIdentifier;
@property (nonatomic,copy,readonly) NSString *displayName;
@end

@interface FBSApplicationPlaceholder : FBSBundleInfo
@property(getter=isPausable) BOOL pausable;
@property(getter=isResumable) BOOL resumable;
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

@interface FBSApplicationLibrary : NSObject
-(NSArray*)allPlaceholders;
@end

#pragma mark UserNotificationsKit & UserNotificationsUIKit Framework

@interface NCNotificationRequest : NSObject
@property BBBulletin *bulletin;
@property (nonatomic,copy,readonly) NSString *threadIdentifier;
@end

@interface NCNotificationAction : NSObject
@property (nonatomic,copy,readonly) NSString *identifier;
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
//@property(nonatomic, strong) UILabel *additionalLabel;
-(void)customContentRequestsDismiss:(id)content;
-(void)setupContent;
-(void)resetContent;
@end

@interface NCNotificationShortLookViewController : NCNotificationViewController
@end

@interface NCNotificationLongLookViewController : NCNotificationViewController
@end

@interface NCNotificationListCell : UIView
@property NCNotificationViewController *contentViewController;
@end