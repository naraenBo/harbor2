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

- (void)follow:(id)arg1 {
  if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=e_swick"]];
  } else {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.twitter.com/e_swick"]];
  }
}

- (void)paypal:(id)arg1 {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.me/eswickdev"]];
}

- (void)bitcoin:(id)arg1 {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://live.blockcypher.com/btc/address/3AGQUpxeiJwKRXUSnJToa7itjeNMzKeveq/"]];
}

- (void)github:(id)arg1 {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.github.com/eswick/harbor2"]];
}

@end
