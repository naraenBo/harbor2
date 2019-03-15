#include "HBRRootListController.h"
#include "../HBRPrefs.h"

#define prefs [HBRPrefs sharedInstance]

@implementation HBRRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}

- (NSNumber*)waveWidth:(PSSpecifier*)specifier {
	return [NSNumber numberWithFloat:[prefs waveWidth]];
}

- (void)setWaveWidth:(NSNumber*)waveWidth forSpecifier:(NSNumber*)specifier {
	[prefs setWaveWidth:[waveWidth floatValue]];
}

- (NSNumber*)waveHeight:(PSSpecifier*)specifier {
	return [NSNumber numberWithFloat:[prefs waveHeight]];
}

- (void)setWaveHeight:(NSNumber*)waveHeight forSpecifier:(NSNumber*)specifier {
	[prefs setWaveHeight:[waveHeight floatValue]];
}

- (NSNumber*)smoothness:(PSSpecifier*)specifier {
	return [NSNumber numberWithFloat:[prefs smoothness]];
}

- (void)setSmoothness:(NSNumber*)smoothness forSpecifier:(NSNumber*)specifier {
	[prefs setSmoothness:[smoothness floatValue]];
}


- (NSNumber*)xTranslation:(PSSpecifier*)specifier {
	return [NSNumber numberWithFloat:[prefs xTranslation]];
}

- (void)setXTranslation:(NSNumber*)xTranslation forSpecifier:(NSNumber*)specifier {
	[prefs setXTranslation:[xTranslation floatValue]];
}

@end
