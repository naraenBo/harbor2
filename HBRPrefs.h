

@interface HBRPrefs : NSObject

+ (HBRPrefs*)sharedInstance;

- (CGFloat)waveWidth;
- (void)setWaveWidth:(CGFloat)waveWidth;

- (CGFloat)waveHeight;
- (void)setWaveHeight:(CGFloat)waveHeight;

- (CGFloat)smoothness;
- (void)setSmoothness:(CGFloat)smoothness;

- (CGFloat)xTranslation;
- (void)setXTranslation:(CGFloat)xTranslation;

@end
