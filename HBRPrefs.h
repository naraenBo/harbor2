

@interface HBRPrefs : NSObject

+ (HBRPrefs*)sharedInstance;

- (CGFloat)waveWidth;
- (void)setWaveWidth:(CGFloat)waveWidth;

- (CGFloat)waveHeight;
- (void)setWaveHeight:(CGFloat)waveHeight;

- (BOOL)springAnimationEnabled;
- (void)setSpringAnimationEnabled:(BOOL)enabled;

@end
