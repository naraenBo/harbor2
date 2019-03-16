#import "HBRPrefs.h"
#import <notify.h>

#define __PREFS_STORE [@"~/Library/Preferences/com.eswick.harbor2.plist" stringByExpandingTildeInPath]

static const NSString* kWaveWidthKey = @"waveWidth";
static const NSString* kWaveHeightKey = @"waveHeight";
static const NSString* kSpringAnimationEnabledKey = @"springAnimationEnabled";

static const char* kPreferencesChangedNotificationKey = "com.eswick.harbor2.preferences_changed";

#define __DEFAULTS @ { \
  kWaveWidthKey : @100.0, \
  kWaveHeightKey : @100.0, \
  kSpringAnimationEnabledKey : @(YES) \
}

@interface HBRPrefs ()

@property (nonatomic, retain) NSMutableDictionary *_preferences;

- (void)savePreferences;

@end

@implementation HBRPrefs

- (void)savePreferences {
  [self._preferences writeToFile:__PREFS_STORE atomically:YES];
  notify_post(kPreferencesChangedNotificationKey);
}

- (CGFloat)waveWidth {
  return [self._preferences[kWaveWidthKey] floatValue];
}

- (void)setWaveWidth:(CGFloat)waveWidth {
  self._preferences[kWaveWidthKey] = @(waveWidth);
  [self savePreferences];
}

- (CGFloat)waveHeight {
  return [self._preferences[kWaveHeightKey] floatValue];
}

- (void)setWaveHeight:(CGFloat)waveHeight {
  self._preferences[kWaveHeightKey] = @(waveHeight);
  [self savePreferences];
}

- (BOOL)springAnimationEnabled {
  return [self._preferences[kSpringAnimationEnabledKey] boolValue];
}

- (void)setSpringAnimationEnabled:(BOOL)enabled {
  self._preferences[kSpringAnimationEnabledKey] = @(enabled);
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

        status = notify_register_dispatch(kPreferencesChangedNotificationKey, &token,
          dispatch_get_main_queue(), ^(int t) {
            _prefs._preferences = [NSMutableDictionary dictionaryWithContentsOfFile:__PREFS_STORE];
        });
    }

    return _prefs;
}

@end
