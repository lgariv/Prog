@import Foundation;
@import UIKit;

@interface UIImage(fetchAppIcon)
+(instancetype)_applicationIconImageForBundleIdentifier:(NSString*)bundleId format:(int)format;
@end

@interface fetchAppIcon : NSObject
@property (atomic, retain, readwrite) UIImage *image;
-(id)init ;
-(UIImage*)imageWithApplicationBundleIdentifier:(NSString*)bundleId ;
@end
