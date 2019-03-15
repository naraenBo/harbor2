#import "HBRPrefs.h"
#import <notify.h>

#define __PREFS_STORE [@"~/Library/Preferences/com.eswick.harbor2.plist" stringByExpandingTildeInPath]

#define __DEFAULTS @ { \
  @"waveWidth" : @100.0, \
  @"waveHeight" : @100.0, \
  @"smoothness" : @50.0 \
  @"xTranslation" : @50.0 \
}

@interface HBRPrefs ()

@property (nonatomic, retain) NSMutableDictionary *_preferences;

- (void)savePreferences;

@end

@implementation HBRPrefs

- (void)savePreferences {
  [self._preferences writeToFile:__PREFS_STORE atomically:YES];
  notify_post("com.eswick.harbor2.preferences_changed");
}

- (CGFloat)waveWidth {
  return [self._preferences[@"waveWidth"] floatValue];
}

- (void)setWaveWidth:(CGFloat)waveWidth {
  self._preferences[@"waveWidth"] = @(waveWidth);
  [self savePreferences];
}

- (CGFloat)waveHeight {
  return [self._preferences[@"waveHeight"] floatValue];
}

- (void)setWaveHeight:(CGFloat)waveHeight {
  self._preferences[@"waveHeight"] = @(waveHeight);
  [self savePreferences];
}

- (CGFloat)smoothness {
  return [self._preferences[@"smoothness"] floatValue];
}

- (void)setSmoothness:(CGFloat)smoothness {
  self._preferences[@"smoothness"] = @(smoothness);
  [self savePreferences];
}

- (CGFloat)xTranslation {
  return [self._preferences[@"xTranslation"] floatValue];
}

- (void)setXTranslation:(CGFloat)xTranslation {
  self._preferences[@"xTranslation"] = @(xTranslation);
  [self savePreferences];
}

+ (HBRPrefs*)sharedInstance {
    static HBRPrefs *_prefs;

    if (_prefs == nil)
    {
        _prefs = [[self alloc] init];

        if(![[NSFileManager defaultManager] fileExistsAtPath:__PREFS_STORE]) {
        	[__DEFAULTS writeToFile:__PREFS_STORE atomically:YES];
        }

        _prefs._preferences = [NSMutableDictionary dictionaryWithContentsOfFile:__PREFS_STORE];

        int token, status;

        status = notify_register_dispatch("com.eswick.harbor2.preferences_changed", &token,
          dispatch_get_main_queue(), ^(int t) {
            _prefs._preferences = [NSMutableDictionary dictionaryWithContentsOfFile:__PREFS_STORE];
        });
    }

    return _prefs;
}

@end
