#line 1 "/Users/ng/Dropbox/DockShift/DockShift/DockShift.xm"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

#pragma mark - Defines

#define STYLEFOR70				[_stylesFor70[_styleIndex] intValue]
#define STYLEFOR71				[_stylesFor71[_styleIndex] intValue]
#define STYLEFOR81_LANDSCAPE	[_stylesFor71[_landscapeStyleIndex] intValue]
#define STYLEFOR9				[_stylesFor9[_styleIndex] intValue]
#define STYLEFOR9_LANDSCAPE		[_stylesFor9[_landscapeStyleIndex] intValue]



#define kLogPrefix @"[DockShift]"

static void LWLog(NSString* format, ...){
	va_list args;
	va_start(args, format);
	NSString* joinedStrings=[[NSString alloc] initWithFormat:format arguments:args];
	va_end(args);
#ifdef kLogPrefix
	NSLog(@"%@ %@", kLogPrefix, joinedStrings); 
#else
	NSLog(@"%@", joinedStrings);
#endif
#ifdef kLogFilePath
	joinedStrings=[[NSString alloc] initWithFormat:@"%@ %@: %@\n", [[NSDate date] description], [[NSProcessInfo processInfo] processName], joinedStrings];
	NSFileManager *fileManager=[NSFileManager defaultManager];
	if(![fileManager fileExistsAtPath:kLogFilePath]){
		[joinedStrings writeToFile:kLogFilePath atomically:NO encoding:NSUTF8StringEncoding error:nil];
	}else{
		NSFileHandle *myHandle=[NSFileHandle fileHandleForWritingAtPath:kLogFilePath];
		[myHandle seekToEndOfFile];
		[myHandle writeData:[joinedStrings dataUsingEncoding:NSUTF8StringEncoding]];
	}
#endif
#if  ! __has_feature(objc_arc)
	[joinedStrings release];
#endif
}

#ifdef DEBUG
#   define LWLog(...) LWLog(__VA_ARGS__)
#else
#   define LWLog(...)
#endif


#pragma mark - Class Interfaces, Funtion Prototypes, ...

@interface SBDockView : UIView
-(void)_backgroundContrastDidChange:(id)arg1 ;

-(void)ds_updateDockBackgroundStyle;
-(void)ds_removeWhiteLine;
@end

@interface SBRootFolderView
-(SBDockView*)dockView;
@end

@interface SBRootFolderController
-(SBRootFolderView*)contentView;
@end

@interface SBHighlightView : UIView
@end

@interface SBIconController
+(SBIconController*)sharedInstance;
-(SBRootFolderController*)_rootFolderController;
@end

@interface SBWallpaperEffectView
-(void)setStyle:(NSInteger)style;
@end

@interface _SBDockBackgroundView
-(void)setStyle:(NSInteger)style;
@end

@interface SBIconListPageControl : UIView
@end

#pragma mark C Function Prototypes

static void updateDockBackgroundView();
extern "C" BOOL _UIAccessibilityEnhanceBackgroundContrast();
BOOL my_UIAccessibilityEnhanceBackgroundContrast();

#pragma mark Other Definitions

enum DOCKMODE{
	DEFAULT=0,
	NONE,
	NONESTRETCHED,
	SMALLWITHLABELS,
	SMALLWITHOUTLABELS,
	SMALLSEATEDICONS,
	DEFAULTLOWEREDICONS,
	DEFAULTSEATEDICONS
};


#pragma mark - Static Variables

static NSArray* _stylesFor70=@[@9,
							   @16,@7,@6,@17,@10,@14,
							   @8,@11,
							   @12,@5,@3];





static NSArray* _stylesFor71=@[@14,
							   @22,@9,@11,@23,@16,@20,
							   @12,@17,
							   @19,@3,@4];
static NSArray* _stylesFor9=@[@15,
							  @9,@23,@12,@10,@24,@27,
							  @18,@25,
							  @3,@8,@6];

static const BOOL _oniPad=UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
static BOOL _forceEffectViewDockBackground=NO;

static BOOL _enabled=YES;
static NSInteger _dockMode=DEFAULT;
static BOOL _shiftPageControl=NO;
static BOOL _hidePageControl=NO;
static NSInteger _styleIndex=3;
static NSInteger _landscapeStyleIndex=3;

#ifdef SCREENSHOT_MODE
static int style=25;
static BOOL firstStyle=YES;
#endif

#pragma mark - Functions

static void loadSettings(){
	LWLog(@"loading settings");
	NSDictionary* settings=(NSDictionary *)CFPreferencesCopyMultiple(CFPreferencesCopyKeyList(CFSTR("de.ng.DockShift"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost), CFSTR("de.ng.DockShift"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	LWLog(@"%@", settings);
	if (!settings) {
		return;
	}
	
	id temp=[settings objectForKey:@"style"];
	_styleIndex=temp ? [temp integerValue] : 3;
	LWLog(@"loadSettings _styleIndex: %i", _styleIndex);
	if(_styleIndex < 0 || _styleIndex > 11){
		_styleIndex=3;
	}
	
	temp=[settings objectForKey:@"landscapeStyle"];
	_landscapeStyleIndex=temp ? [temp integerValue] : 3;
	LWLog(@"loadSettings _landscapeStyleIndex: %i", _landscapeStyleIndex);
	if(_landscapeStyleIndex < 0 || _landscapeStyleIndex > 11){
		_landscapeStyleIndex=3;
	}
	
	temp=[settings objectForKey:@"enabled"];
	_enabled=temp ? [temp boolValue] : NO;
	
	temp=[settings objectForKey:@"dockmode"];
	_dockMode=temp ? [temp integerValue] : 0;
	
	temp=[settings objectForKey:@"shiftedpagecontrol"];
	_shiftPageControl=temp ? [temp boolValue] && _styleIndex==0 : NO;
	
	temp=[settings objectForKey:@"hiddenpagecontrol"];
	_hidePageControl=temp ? [temp boolValue] : NO;
	
	[temp release];
	[settings release];

	#ifdef SCREENSHOT_MODE
	if (firstStyle) {
		firstStyle=NO;
	} else {
		style++;
	}
	#endif
}

static void settingsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){
	loadSettings();
	updateDockBackgroundView();
}

#include <logos/logos.h>
#include <substrate.h>
@class SBAppSwitcherContainer; @class _SBDockBackgroundView; @class SBWallpaperEffectView; @class UIView; @class SBMedusaSettings; @class SpringBoard; @class SBDockIconListView; @class SBDockView; @class SBIconListPageControl; @class SBIconController; @class SBScreenShotter; 

static __inline__ __attribute__((always_inline)) Class _logos_static_class_lookup$_SBDockBackgroundView(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("_SBDockBackgroundView"); } return _klass; }static __inline__ __attribute__((always_inline)) Class _logos_static_class_lookup$SBAppSwitcherContainer(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBAppSwitcherContainer"); } return _klass; }static __inline__ __attribute__((always_inline)) Class _logos_static_class_lookup$SBMedusaSettings(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBMedusaSettings"); } return _klass; }static __inline__ __attribute__((always_inline)) Class _logos_static_class_lookup$SBScreenShotter(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBScreenShotter"); } return _klass; }static __inline__ __attribute__((always_inline)) Class _logos_static_class_lookup$SBWallpaperEffectView(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBWallpaperEffectView"); } return _klass; }static __inline__ __attribute__((always_inline)) Class _logos_static_class_lookup$SBIconController(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBIconController"); } return _klass; }
#line 194 "/Users/ng/Dropbox/DockShift/DockShift/DockShift.xm"
static void updateDockBackgroundView(){
	id dockView=[[[[_logos_static_class_lookup$SBIconController() sharedInstance] _rootFolderController] contentView] dockView];
	[dockView ds_updateDockBackgroundStyle];
	if([dockView respondsToSelector:@selector(_backgroundContrastDidChange:)]){
		[dockView _backgroundContrastDidChange:nil];
	}
}


#pragma mark - Hooks

#pragma mark Function Hooks

static BOOL (*their_UIAccessibilityEnhanceBackgroundContrast)();
BOOL my_UIAccessibilityEnhanceBackgroundContrast(){
	if(their_UIAccessibilityEnhanceBackgroundContrast()){
		
		if(_enabled && _forceEffectViewDockBackground){
			
			LWLog(@"my_UIAccessibilityEnhanceBackgroundContrast() was called and _forceEffectViewDockBackground==YES, returning NO");
			return NO;
		}else{
			return YES;
		}
	}
	return NO;
}


#pragma mark Method Hooks

static id (*_logos_orig$SpringBoard_General$SBDockView$initWithDockListView$forSnapshot$)(SBDockView*, SEL, id, BOOL); static id _logos_method$SpringBoard_General$SBDockView$initWithDockListView$forSnapshot$(SBDockView*, SEL, id, BOOL); static void (*_logos_orig$SpringBoard_General$SBDockView$_backgroundContrastDidChange$)(SBDockView*, SEL, id); static void _logos_method$SpringBoard_General$SBDockView$_backgroundContrastDidChange$(SBDockView*, SEL, id); static void (*_logos_orig$SpringBoard_General$SBDockView$layoutSubviews)(SBDockView*, SEL); static void _logos_method$SpringBoard_General$SBDockView$layoutSubviews(SBDockView*, SEL); static void _logos_method$SpringBoard_General$SBDockView$ds_updateDockBackgroundStyle(SBDockView*, SEL); static void _logos_method$SpringBoard_General$SBDockView$ds_removeWhiteLine(SBDockView*, SEL); static CGFloat (*_logos_orig$SpringBoard_General$SBDockIconListView$topIconInset)(SBDockIconListView*, SEL); static CGFloat _logos_method$SpringBoard_General$SBDockIconListView$topIconInset(SBDockIconListView*, SEL); static void (*_logos_orig$SpringBoard_General$SBIconListPageControl$setBounds$)(SBIconListPageControl*, SEL, CGRect); static void _logos_method$SpringBoard_General$SBIconListPageControl$setBounds$(SBIconListPageControl*, SEL, CGRect); static void (*_logos_orig$SpringBoard_General$SBIconListPageControl$layoutSubviews)(SBIconListPageControl*, SEL); static void _logos_method$SpringBoard_General$SBIconListPageControl$layoutSubviews(SBIconListPageControl*, SEL); static void (*_logos_orig$SpringBoard_General$SpringBoard$applicationDidFinishLaunching$)(SpringBoard*, SEL, UIApplication*); static void _logos_method$SpringBoard_General$SpringBoard$applicationDidFinishLaunching$(SpringBoard*, SEL, UIApplication*); static BOOL (*_logos_meta_orig$SpringBoard_General$UIView$_motionEffectsSupported)(Class, SEL); static BOOL _logos_meta_method$SpringBoard_General$UIView$_motionEffectsSupported(Class, SEL); 



static id _logos_method$SpringBoard_General$SBDockView$initWithDockListView$forSnapshot$(SBDockView* self, SEL _cmd, id dockListView, BOOL snapshot){
	_forceEffectViewDockBackground=YES;
	id r=_logos_orig$SpringBoard_General$SBDockView$initWithDockListView$forSnapshot$(self, _cmd, dockListView, snapshot);
	_forceEffectViewDockBackground=NO;
	[self ds_removeWhiteLine];
	return r;
}

static void _logos_method$SpringBoard_General$SBDockView$_backgroundContrastDidChange$(SBDockView* self, SEL _cmd, id arg1){
	_forceEffectViewDockBackground=YES;
	_logos_orig$SpringBoard_General$SBDockView$_backgroundContrastDidChange$(self, _cmd, arg1);
	_forceEffectViewDockBackground=NO;
}

static void _logos_method$SpringBoard_General$SBDockView$layoutSubviews(SBDockView* self, SEL _cmd){
	_logos_orig$SpringBoard_General$SBDockView$layoutSubviews(self, _cmd);
	[self ds_updateDockBackgroundStyle];
	self.hidden=(_dockMode==NONE);
}


static void _logos_method$SpringBoard_General$SBDockView$ds_updateDockBackgroundStyle(SBDockView* self, SEL _cmd){
	id currentBackgroundView=MSHookIvar<id>(self, "_backgroundView");
	if([currentBackgroundView isMemberOfClass:[_logos_static_class_lookup$SBWallpaperEffectView() class]] && [currentBackgroundView respondsToSelector:@selector(setStyle:)]){
		LWLog(@"Updating background style for iOS 7.1 or 8.1+, _styleIndex=%i", _styleIndex);
		UIInterfaceOrientation orientation=[UIApplication sharedApplication].statusBarOrientation;
		if(([_logos_static_class_lookup$SBAppSwitcherContainer() class] || [_logos_static_class_lookup$SBMedusaSettings() class]) && (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)){
			
			LWLog(@"orientation is landscape");
			#ifndef SCREENSHOT_MODE
			int style;
			if ([_logos_static_class_lookup$SBAppSwitcherContainer() class]) {
				style = _enabled ? STYLEFOR81_LANDSCAPE : 11;
			} else if ([_logos_static_class_lookup$SBMedusaSettings() class]) {
				style = _enabled ? STYLEFOR9_LANDSCAPE : 7;
			}
			#endif
			[(SBWallpaperEffectView*)currentBackgroundView setStyle:style];
		}else{
			
			#ifndef SCREENSHOT_MODE
			int style;
			if ([_logos_static_class_lookup$SBMedusaSettings() class]) {
				
				style = _enabled ? STYLEFOR9 : 7;
			} else {
				
				style = _enabled ? STYLEFOR71 : 11;
			}
			#endif
			LWLog(@"orientation is portrait or we're on iOS7, style=%i", style);
			
			[(SBWallpaperEffectView*)currentBackgroundView setStyle:style];
		}
	}else if([currentBackgroundView isMemberOfClass:[_logos_static_class_lookup$_SBDockBackgroundView() class]] && [currentBackgroundView respondsToSelector:@selector(setStyle:)]){
		LWLog(@"Updating background style for iOS 7.0");
		
		[(_SBDockBackgroundView*)currentBackgroundView setStyle:_enabled ? STYLEFOR70 : 7];
	}
	[self ds_removeWhiteLine];
}


static void _logos_method$SpringBoard_General$SBDockView$ds_removeWhiteLine(SBDockView* self, SEL _cmd){
	if(_enabled){
		SBHighlightView* highlightView=MSHookIvar<SBHighlightView*>(self, "_highlightView");
		
		[highlightView removeFromSuperview];
		[highlightView setHidden:YES];
		[highlightView setAlpha:0];
	}
}





static CGFloat _logos_method$SpringBoard_General$SBDockIconListView$topIconInset(SBDockIconListView* self, SEL _cmd){
	if(_dockMode != DEFAULT){
        LWLog(@"Shifting topIconInset");
		switch(_dockMode){
			case NONESTRETCHED: return 200;
			case SMALLWITHLABELS: return _oniPad?24:19;
			case SMALLWITHOUTLABELS: return _oniPad?41:32;
			case SMALLSEATEDICONS: return _oniPad?48:36;
			case DEFAULTLOWEREDICONS: return _oniPad?38:33;
			case DEFAULTSEATEDICONS: return _oniPad?48:36;
		}
	}
	return _logos_orig$SpringBoard_General$SBDockIconListView$topIconInset(self, _cmd);
}





static void _logos_method$SpringBoard_General$SBIconListPageControl$setBounds$(SBIconListPageControl* self, SEL _cmd, CGRect bounds){
	if(_enabled && _shiftPageControl){
        LWLog(@"Shifting page dots");
		CGFloat y=0;
		switch(_dockMode){
			case DEFAULT: y=_oniPad?0:-5; break;
			case DEFAULTLOWEREDICONS: y=_oniPad?0:-15; break;
			case DEFAULTSEATEDICONS: y=_oniPad?0:-17; break;
		}
		_logos_orig$SpringBoard_General$SBIconListPageControl$setBounds$(self, _cmd, CGRectMake(bounds.origin.x, y, bounds.size.width, bounds.size.height));
	}else{
		_logos_orig$SpringBoard_General$SBIconListPageControl$setBounds$(self, _cmd, bounds);
	}	
}

static void _logos_method$SpringBoard_General$SBIconListPageControl$layoutSubviews(SBIconListPageControl* self, SEL _cmd){
	_logos_orig$SpringBoard_General$SBIconListPageControl$layoutSubviews(self, _cmd);
	if(_enabled && _hidePageControl){
        LWLog(@"Hiding page dots");
		self.hidden=YES;
	}
}





static void _logos_method$SpringBoard_General$SpringBoard$applicationDidFinishLaunching$(SpringBoard* self, SEL _cmd, UIApplication* application){
	_logos_orig$SpringBoard_General$SpringBoard$applicationDidFinishLaunching$(self, _cmd, application);
	updateDockBackgroundView();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, settingsChanged, CFSTR("de.ng.DockShift.settingsChanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}





static BOOL _logos_meta_method$SpringBoard_General$UIView$_motionEffectsSupported(Class self, SEL _cmd){
	if(_forceEffectViewDockBackground){
		
		
		return YES;
	}
	return _logos_meta_orig$SpringBoard_General$UIView$_motionEffectsSupported(self, _cmd);
}






static CGFloat (*_logos_orig$SpringBoard_iOS7$SBDockView$heightForOrientation$)(SBDockView*, SEL, NSInteger); static CGFloat _logos_method$SpringBoard_iOS7$SBDockView$heightForOrientation$(SBDockView*, SEL, NSInteger); 



static CGFloat _logos_method$SpringBoard_iOS7$SBDockView$heightForOrientation$(SBDockView* self, SEL _cmd, NSInteger orientation){
	CGFloat r=_logos_orig$SpringBoard_iOS7$SBDockView$heightForOrientation$(self, _cmd, orientation);
	if(_dockMode != DEFAULT){
        LWLog(@"Changing heightForOrientation");
		if(_dockMode==SMALLWITHLABELS){
			r=_oniPad?111:88;
		}else if(_dockMode==SMALLWITHOUTLABELS){
			r=_oniPad?90:69;
		}else if(_dockMode==SMALLSEATEDICONS){
			r=_oniPad?76:60;
		}else if(_dockMode==NONESTRETCHED){
			r=-10;
		}
	}
	return r;
}






static __attribute__((constructor)) void _logosLocalCtor_14b1a26b() {
	loadSettings();
	MSHookFunction(_UIAccessibilityEnhanceBackgroundContrast,
				   my_UIAccessibilityEnhanceBackgroundContrast,
				   &their_UIAccessibilityEnhanceBackgroundContrast);
    LWLog(@"Loading general hooks");
	{Class _logos_class$SpringBoard_General$SBDockView = objc_getClass("SBDockView"); MSHookMessageEx(_logos_class$SpringBoard_General$SBDockView, @selector(initWithDockListView:forSnapshot:), (IMP)&_logos_method$SpringBoard_General$SBDockView$initWithDockListView$forSnapshot$, (IMP*)&_logos_orig$SpringBoard_General$SBDockView$initWithDockListView$forSnapshot$);MSHookMessageEx(_logos_class$SpringBoard_General$SBDockView, @selector(_backgroundContrastDidChange:), (IMP)&_logos_method$SpringBoard_General$SBDockView$_backgroundContrastDidChange$, (IMP*)&_logos_orig$SpringBoard_General$SBDockView$_backgroundContrastDidChange$);MSHookMessageEx(_logos_class$SpringBoard_General$SBDockView, @selector(layoutSubviews), (IMP)&_logos_method$SpringBoard_General$SBDockView$layoutSubviews, (IMP*)&_logos_orig$SpringBoard_General$SBDockView$layoutSubviews);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$SpringBoard_General$SBDockView, @selector(ds_updateDockBackgroundStyle), (IMP)&_logos_method$SpringBoard_General$SBDockView$ds_updateDockBackgroundStyle, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$SpringBoard_General$SBDockView, @selector(ds_removeWhiteLine), (IMP)&_logos_method$SpringBoard_General$SBDockView$ds_removeWhiteLine, _typeEncoding); }Class _logos_class$SpringBoard_General$SBDockIconListView = objc_getClass("SBDockIconListView"); MSHookMessageEx(_logos_class$SpringBoard_General$SBDockIconListView, @selector(topIconInset), (IMP)&_logos_method$SpringBoard_General$SBDockIconListView$topIconInset, (IMP*)&_logos_orig$SpringBoard_General$SBDockIconListView$topIconInset);Class _logos_class$SpringBoard_General$SBIconListPageControl = objc_getClass("SBIconListPageControl"); MSHookMessageEx(_logos_class$SpringBoard_General$SBIconListPageControl, @selector(setBounds:), (IMP)&_logos_method$SpringBoard_General$SBIconListPageControl$setBounds$, (IMP*)&_logos_orig$SpringBoard_General$SBIconListPageControl$setBounds$);MSHookMessageEx(_logos_class$SpringBoard_General$SBIconListPageControl, @selector(layoutSubviews), (IMP)&_logos_method$SpringBoard_General$SBIconListPageControl$layoutSubviews, (IMP*)&_logos_orig$SpringBoard_General$SBIconListPageControl$layoutSubviews);Class _logos_class$SpringBoard_General$SpringBoard = objc_getClass("SpringBoard"); MSHookMessageEx(_logos_class$SpringBoard_General$SpringBoard, @selector(applicationDidFinishLaunching:), (IMP)&_logos_method$SpringBoard_General$SpringBoard$applicationDidFinishLaunching$, (IMP*)&_logos_orig$SpringBoard_General$SpringBoard$applicationDidFinishLaunching$);Class _logos_class$SpringBoard_General$UIView = objc_getClass("UIView"); Class _logos_metaclass$SpringBoard_General$UIView = object_getClass(_logos_class$SpringBoard_General$UIView); MSHookMessageEx(_logos_metaclass$SpringBoard_General$UIView, @selector(_motionEffectsSupported), (IMP)&_logos_meta_method$SpringBoard_General$UIView$_motionEffectsSupported, (IMP*)&_logos_meta_orig$SpringBoard_General$UIView$_motionEffectsSupported);}
	
	
    if(![_logos_static_class_lookup$SBAppSwitcherContainer() class] && ![_logos_static_class_lookup$SBMedusaSettings() class]){
		LWLog(@"Loading iOS 7 hooks");
		{Class _logos_class$SpringBoard_iOS7$SBDockView = objc_getClass("SBDockView"); MSHookMessageEx(_logos_class$SpringBoard_iOS7$SBDockView, @selector(heightForOrientation:), (IMP)&_logos_method$SpringBoard_iOS7$SBDockView$heightForOrientation$, (IMP*)&_logos_orig$SpringBoard_iOS7$SBDockView$heightForOrientation$);}
	}
	
	LWLog(@"constructor is done");
	
	#ifdef SCREENSHOT_MODE
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		LWLog(@"starting screenshotting");
		int i = 1;
		while (i < (32-style+1)) {
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (i*10) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
				LWLog(@"making screenshot for style %i", style);
				[[_logos_static_class_lookup$SBScreenShotter() sharedInstance] saveScreenshotsShowingFlash:YES completion:^{
					dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (2) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
						loadSettings();
						updateDockBackgroundView();
					});
				}];
			});
			i++;
		}
	});
	#endif
}
