

@interface HBRPrefs : NSObject

+ (HBRPrefs*)sharedInstance;

- (CGFloat)waveWidth;
- (void)setWaveWidth:(CGFloat)waveWidth;

- (CGFloat)waveHeight;
- (void)setWaveHeight:(CGFloat)waveHeight;

@end
