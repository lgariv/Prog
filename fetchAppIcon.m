#import "fetchAppIcon.h"

@implementation fetchAppIcon
-(id)init {
    self.image = [[UIImage alloc] init];
    return self;
}

-(UIImage*)imageWithApplicationBundleIdentifier:(NSString*)bundleId {
    UIImage __block *img = nil;

    // checking if self.image UIImage is empty
    CGImageRef cgref = [self.image CGImage];
    CIImage *cim = [self.image CIImage];

    if (cim == nil && cgref == NULL) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/com.spark.snowboard.md5sums"]) {
            NSMutableDictionary *snowboardPrefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.spark.snowboardprefs.plist"];
            NSArray *pathsArray = (NSArray*)[snowboardPrefs objectForKey:@"ActiveMenuItems"];
            NSMutableArray *themesArray = [[NSMutableArray alloc] init];
            for (NSString *path in pathsArray)
                if ([[path lowercaseString] containsString:@"theme"])
                    [themesArray addObject:path];
            NSFileManager *manager = [NSFileManager defaultManager];
            for (NSString *theme in themesArray) {
                NSString *appIconPath = [NSString stringWithFormat:@"%@%@%@%@", theme, @"/IconBundles/", bundleId, @"-large.png"];
                if ([manager fileExistsAtPath:appIconPath]) {
                    img = [UIImage imageWithContentsOfFile:appIconPath];
                    self.image = img;
                    break;
                }
            }
            CGImageRef cgref = [self.image CGImage];
            CIImage *cim = [self.image CIImage];
            if (cim == nil && cgref == NULL) {} else return img;
        }
        // @try {
        //     NSString *appInfoUrl = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@", bundleId];

        //     NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:appInfoUrl]];

        //     NSError *e = nil;
        //     NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error: &e];

        //     NSString *artworkUrl60 = [[[jsonDict objectForKey:@"results"] objectAtIndex:0] objectForKey:@"artworkUrl60"];
        //     NSURL *iconUrl = [NSURL URLWithString:artworkUrl60];
        //     NSData *iconData = [NSData dataWithContentsOfURL:iconUrl];
        //     img = [UIImage imageWithData: iconData];
        //     self.image = img;
        // }
        // @catch (NSException *x) {
        //     NSLog(@"[Prog][fetchAppIcon] Couldn't fetch app icon from iTunes API, using the one cached in the system if available.\n[Prog][fetchAppIcon] exception: %@", x);
    		img = [UIImage _applicationIconImageForBundleIdentifier:bundleId format:1];
        // }
    } else {
        img = self.image;
    }

    return img;
}
@end
