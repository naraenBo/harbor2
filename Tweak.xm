#pragma mark Definitions

#define __MAX_ICONS 50
#define __WAVE_WIDTH 100.0
#define __WAVE_HEIGHT 100.0
#define __CANCEL_GESTURE_RANGE 5.0
#define __ANIMATION_DURATION 0.2
#define __PLIST_STORE [@"~/Library/SpringBoard/IconState_harbor.plist" stringByExpandingTildeInPath]

struct SBIconCoordinate {
    long long row;
    long long col;
};

@interface SBApplication : NSObject

- (NSString *)bundleIdentifier;

@end

@interface SBIcon : NSObject

- (SBApplication *)application;

@end

@interface SBIconView : UIView

+ (CGSize)defaultIconImageSize;
+ (CGRect)defaultIconImageFrame;

- (SBIcon *)icon;
- (BOOL)isInDock;
- (CGFloat)iconContentScale;
- (BOOL)isEditing;

@end

@interface SBIconView ()

- (CGFloat)harbor_focusPercentage;
- (void)harbor_setFocusPercentage:(CGFloat)focusPercentage;

@end

@interface SBIconViewMap : NSObject
- (SBIconView *)mappedIconViewForIcon:(SBIcon*)arg1;
@end

@interface SBIconListModel : NSObject
- (SBIcon *)iconAtIndex:(unsigned long long)arg1;
- (unsigned long long)indexForIcon:(SBIcon *)arg1;
- (NSArray<SBIcon *> *)icons;
@end

@interface SBIconListView : UIView

- (SBIconViewMap *)viewMap;
- (SBIconListModel *)model;
- (BOOL)isEditing;

@end

@interface SBDockIconListView : SBIconListView

- (CGPoint)originForIconAtCoordinate:(SBIconCoordinate)arg1;
- (CGSize)scaledAlignmentIconSize;

@end

@interface SBDockIconListView ()
- (void)harbor_updateIconTransformsWithPoint:(CGPoint)touchPoint;
- (void)harbor_resetIconTransforms;


- (void)harbor_updateIconTransformsWithPointAnimated:(CGPoint)touchPoint;
- (void)harbor_resetIconTransformsAnimated;

- (SBIcon *)harbor_selectedIconWithPoint:(CGPoint)touchPoint;

@end

@interface SBIconModel : NSObject

- (void)_saveIconState;

@end

@interface SBIconController

+ (SBIconController*)sharedInstance;

@property(retain, nonatomic) SBIconModel *model;

- (SBDockIconListView *)floatingDockListView;
- (void)iconTapped:(id)arg1;

@end

typedef NS_ENUM(NSInteger, SBEnvironmentMode) {
  SBEnvironmentModeHomeScreen = 1,
  SBEnvironmentModeSwitcher,
  SBEnvironmentModeApp
};

@interface SBMainDisplayLayoutState

@property(readonly, nonatomic) SBEnvironmentMode unlockedEnvironmentMode;

@end

@interface SBMainDisplaySceneLayoutViewController

@property(readonly, nonatomic) SBMainDisplayLayoutState *layoutState;

@end

@interface SBFluidSwitcherViewController : UIViewController

- (SBIconView*)iconViewForAppLayout:(id)arg1;

@end

@interface SBIconModelPropertyListFileStore : NSObject

@property(retain, nonatomic) NSURL *currentIconStateURL;

@end

@interface SBDefaultIconModelStore : SBIconModelPropertyListFileStore

@end

#pragma mark Enable Floating Dock

%hook SBFloatingDockBehaviorAssertion

// Disable floating dock inside apps for iPhone X
- (BOOL)gesturePossible {
  return NO;
}

%end

%hook SBFloatingDockController

+ (BOOL)isFloatingDockSupported {
  return YES;
}

// Disable Recents and Continuity sections in dock
- (id)initWithIconController:(id)arg1 applicationController:(id)arg2 recentsController:(id)arg3 recentsDataStore:(id)arg4 transitionCoordinator:(id)arg5 appSuggestionManager:(id)arg6 analyticsClient:(id)arg7 {
  return %orig(arg1, arg2, nil, arg4, arg5, nil, arg7);
}

%end

%hook SBDockIconListView

+ (int)maxIcons {
  return __MAX_ICONS;
}

%end

#pragma mark Touch Handling

%hook SBDockIconListView

%new
- (SBIcon*)harbor_selectedIconWithPoint:(CGPoint)touchPoint {

  if (self.model.icons.count == 0)
    return nil;

  SBIcon *closestIcon = self.model.icons[0];

  for (SBIcon *icon in self.model.icons) {
    unsigned long long iconViewIndex = [self.model indexForIcon:icon];
    CGPoint iconOrigin = [self originForIconAtCoordinate:(struct SBIconCoordinate){ .row = 0, .col = iconViewIndex + 1}];

    unsigned long long closestIconIndex = [self.model indexForIcon:closestIcon];
    CGPoint closestIconOrigin = [self originForIconAtCoordinate:(struct SBIconCoordinate){ .row = 0, .col = closestIconIndex + 1}];

    CGFloat offset = touchPoint.x - (iconOrigin.x + ([self scaledAlignmentIconSize].width / 2));
    CGFloat closestIconOffset = touchPoint.x - (closestIconOrigin.x + ([self scaledAlignmentIconSize].width / 2));

    if (fabs(offset) < fabs(closestIconOffset)) {
      closestIcon = icon;
    }
  }

  return closestIcon;
}

%new
- (void)harbor_updateIconTransformsWithPoint:(CGPoint)touchPoint {

   for (SBIcon *icon in self.model.icons) {
     SBIconView *iconView = [self.viewMap mappedIconViewForIcon:icon];
     unsigned long long index = [self.model indexForIcon:icon];

     CGSize scaledAlignmentIconSize = [self scaledAlignmentIconSize];
     CGSize defaultIconSize = [%c(SBIconView) defaultIconImageSize];

     CGPoint originalIconOrigin = [self originForIconAtCoordinate:(struct SBIconCoordinate){.row = 0, .col = index + 1}];
     CGFloat offset = touchPoint.x - (originalIconOrigin.x + (scaledAlignmentIconSize.width / 2));

     CGFloat yOffset = 0.0;

     if (offset < __WAVE_WIDTH && offset > -__WAVE_WIDTH)
      yOffset = ((cos((M_PI * offset) / __WAVE_WIDTH) + 1) / 2) * __WAVE_HEIGHT;

     CGAffineTransform translation = CGAffineTransformMakeTranslation(0.0, -yOffset);

     CGFloat percentage = yOffset / __WAVE_HEIGHT;
     CGFloat normalizedWidth = scaledAlignmentIconSize.width + (defaultIconSize.width - scaledAlignmentIconSize.width) * percentage;
     CGFloat scale = normalizedWidth / scaledAlignmentIconSize.width;

     [iconView harbor_setFocusPercentage:percentage];

     iconView.transform = CGAffineTransformScale(translation, scale, scale);
   }

   for (SBIcon *icon in self.model.icons) {
     SBIconView *iconView = [self.viewMap mappedIconViewForIcon:icon];
     unsigned long long index = [self.model indexForIcon:icon];

     CGPoint originalIconOrigin = [self originForIconAtCoordinate:(struct SBIconCoordinate){.row = 0, .col = index + 1}];
     CGFloat offset = touchPoint.x - (originalIconOrigin.x + ([self scaledAlignmentIconSize].width / 2));

     CGFloat xOffset = -(atan(offset / (__WAVE_WIDTH / 2)) / (M_PI / 2)) * (__WAVE_WIDTH / 2);

     iconView.transform = CGAffineTransformTranslate(iconView.transform, xOffset, 0.0);
   }
}

%new
- (void)harbor_resetIconTransforms {
  for (SBIcon *icon in self.model.icons) {
    SBIconView *iconView = [self.viewMap mappedIconViewForIcon:icon];

    iconView.transform = CGAffineTransformIdentity;

    [iconView harbor_setFocusPercentage:0.0];
  }
}

%new
- (void)harbor_updateIconTransformsWithPointAnimated:(CGPoint)touchPoint {
  [UIView animateWithDuration:__ANIMATION_DURATION animations:^{
    [self harbor_updateIconTransformsWithPoint:touchPoint];
  }];
}

%new
- (void)harbor_resetIconTransformsAnimated {
  [UIView animateWithDuration:__ANIMATION_DURATION animations:^{
    [self harbor_resetIconTransforms];
  }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  if ([self isEditing])
    return;

  [self harbor_updateIconTransformsWithPointAnimated:[[touches anyObject] locationInView:self]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  if ([self isEditing]) {
    return;
  }
  [self harbor_updateIconTransformsWithPoint:[[touches anyObject] locationInView:self]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  SBIconView *iconView = [self.viewMap mappedIconViewForIcon:[self harbor_selectedIconWithPoint:[[touches anyObject] locationInView:self]]];

  if ([[touches anyObject] locationInView:self].y > self.bounds.size.height - __CANCEL_GESTURE_RANGE) {
    [self harbor_resetIconTransformsAnimated];
  } else {
    [[%c(SBIconController) sharedInstance] iconTapped:iconView];
  }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [self harbor_resetIconTransformsAnimated];
}

%end

#pragma mark SpringBoard State Change Handlers

%hook SBFluidSwitcherViewController

static SBEnvironmentMode previousEnvironmentMode = SBEnvironmentModeHomeScreen;

- (void)sceneLayoutControllerDidEndLayoutStateTransition:(SBMainDisplaySceneLayoutViewController*)arg1 wasInterrupted:(BOOL)arg2 {

  SBEnvironmentMode toEnvironmentMode = [[arg1 layoutState] unlockedEnvironmentMode];

  if (toEnvironmentMode == SBEnvironmentModeHomeScreen) {
    [[[%c(SBIconController) sharedInstance] floatingDockListView] harbor_resetIconTransformsAnimated];
  }

  %orig;
}

- (void)sceneLayoutController:(id)arg1 didBeginLayoutStateTransitionWithContext:(SBMainDisplaySceneLayoutViewController*)arg2 {

  SBEnvironmentMode toEnvironmentMode = [[arg2 layoutState] unlockedEnvironmentMode];

  if (previousEnvironmentMode == SBEnvironmentModeSwitcher) {
    [[[%c(SBIconController) sharedInstance] floatingDockListView] harbor_resetIconTransformsAnimated];
  }

  if (toEnvironmentMode == SBEnvironmentModeSwitcher) {
    [[[%c(SBIconController) sharedInstance] floatingDockListView] harbor_resetIconTransforms];
  }

  previousEnvironmentMode = toEnvironmentMode;

  %orig;
}

%end

#pragma mark Disable Original Icon Touch Behavior

%hook SBIconView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  if ([self isInDock] && ![self isEditing]) {
    return nil;
  }

  return %orig;
}

%end

%hook SBIconController

- (BOOL)iconViewDisplaysCloseBox:(SBIconView*)arg1 {
  if ([arg1 isInDock]) {
    return NO;
  }

  return %orig;
}

%end

#pragma mark Icon Transition Placeholder Scale Bug Fix

/*
  When launching / closing an app, the placeholder icon does not correctly
  account for the change in icon scale caused by Harbor's zoom effect
*/

static BOOL overrideIconContentScale = NO;
static CGFloat iconContentScaleOverride = 0.0;

%hook SBIconView

- (CGFloat)iconContentScale {
  if (overrideIconContentScale) {
    return iconContentScaleOverride;
  } else {
    return %orig;
  }
}

%new
- (CGFloat)harbor_focusPercentage {
  NSNumber *focusPercentage = objc_getAssociatedObject(self, @selector(harbor_focusPercentage));

  if (focusPercentage) {
    return [focusPercentage floatValue];
  } else {
    return 0.0;
  }
}

%new
- (void)harbor_setFocusPercentage:(CGFloat)focusPercentage {
  objc_setAssociatedObject(self, @selector(harbor_focusPercentage), [NSNumber numberWithFloat:focusPercentage], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%end

%hook SBFluidSwitcherViewController

- (CGRect)_iconImageFrameForIconView:(SBIconView*)arg1 {

  CGFloat originalScale = [arg1 iconContentScale];

  overrideIconContentScale = YES;
  iconContentScaleOverride = originalScale + (1.0 - originalScale) * [arg1 harbor_focusPercentage];

  CGRect returnVal = %orig;

  overrideIconContentScale = NO;

  return returnVal;
}

- (CGFloat)iconCornerRadiusForAppLayout:(id)arg1 {

  SBIconView *iconView = [self iconViewForAppLayout:arg1];
  CGFloat returnVal = 0.0;

  if (!iconView) {
    overrideIconContentScale = YES;
    iconContentScaleOverride = 1.0;

    returnVal = %orig;

    overrideIconContentScale = NO;

    return returnVal;
  }

  CGFloat originalScale = [iconView iconContentScale];

  overrideIconContentScale = YES;
  iconContentScaleOverride = originalScale + (1.0 - originalScale) * [iconView harbor_focusPercentage];

  returnVal = %orig;

  overrideIconContentScale = NO;

  return returnVal;
}

%end

#pragma mark Alternate Icon Store Location

%hook SBDefaultIconModelStore

- (id)init {
  self = %orig;
  if (self) {
    self.currentIconStateURL = [NSURL fileURLWithPath:__PLIST_STORE];

    if (![[NSFileManager defaultManager] fileExistsAtPath:__PLIST_STORE]) {
      [[[%c(SBIconController) sharedInstance] model] _saveIconState];
    }

  }
  return self;
}

%end
