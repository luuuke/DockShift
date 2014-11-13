#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

#pragma mark - Defines

#define STYLEFOR70 [_stylesFor70[_styleIndex] intValue]
#define STYLEFOR71 [_stylesFor71[_styleIndex] intValue]
#define STYLEFOR81_LANDSCAPE [_stylesFor71[_landscapeStyleIndex] intValue]

//DEBUG section
#define kLogFilePath @"/var/mobile/Documents/de.ng.dockshift.log"
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
//DEBUG section end

#pragma mark - Class Interfaces, Funtion Prototypes, ...

@interface SBDockView : UIView
-(void)_backgroundContrastDidChange:(id)arg1 ;
//%new'd
-(void)updateDockBackgroundStyle;
-(void)removeWhiteLine;
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
/* Legacy from iOS 7.1 beta:
static NSArray* _stylesFor71Beta=@[@12,
							   @19,@9,@8,@20,@13,@17,
							   @10,@14,
							   @15,@6,@4];*/
static NSArray* _stylesFor71=@[@14,
							   @22,@9,@11,@23,@16,@20,
							   @12,@17,
							   @19,@3,@4];

static const BOOL _oniPad=UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
static BOOL _forceEffectViewDockBackground=NO;

static BOOL _enabled=YES;
static NSInteger _dockMode=DEFAULT;
static BOOL _shiftPageControl=NO;
static BOOL _hidePageControl=NO;
static BOOL _forcewhitelineremoval=NO;
static NSInteger _styleIndex=3;
static NSInteger _landscapeStyleIndex=3;

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
	
	temp=[settings objectForKey:@"forcewhitelineremoval"];
	_forcewhitelineremoval=temp ? [temp boolValue] : NO;
	
	temp=[settings objectForKey:@"hiddenpagecontrol"];
	_hidePageControl=temp ? [temp boolValue] : NO;
	
	[temp release];
	[settings release];
}

static void settingsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){
	loadSettings();
	updateDockBackgroundView();
}

static void updateDockBackgroundView(){
	id dockView=[[[[%c(SBIconController) sharedInstance] _rootFolderController] contentView] dockView];
	[dockView updateDockBackgroundStyle];
	if([dockView respondsToSelector:@selector(_backgroundContrastDidChange:)]){
		[dockView _backgroundContrastDidChange:nil];
	}
}


#pragma mark - Hooks

#pragma mark Function Hooks

static BOOL (*their_UIAccessibilityEnhanceBackgroundContrast)();
BOOL my_UIAccessibilityEnhanceBackgroundContrast(){
	if(their_UIAccessibilityEnhanceBackgroundContrast()){
		//enhanced contrast is enabled
		if(_enabled && _forceEffectViewDockBackground){
			//...but we don't want it to be right now
			LWLog(@"my_UIAccessibilityEnhanceBackgroundContrast() was called and _forceEffectViewDockBackground==YES, returning NO");
			return NO;
		}else{
			return YES;
		}
	}
	return NO;
}


#pragma mark Method Hooks

%group SpringBoard_General

%hook SBDockView

-(id)initWithDockListView:(id)dockListView forSnapshot:(BOOL)snapshot{
	_forceEffectViewDockBackground=YES;
	id r=%orig;
	_forceEffectViewDockBackground=NO;
	[self removeWhiteLine];
	return r;
}

-(void)_backgroundContrastDidChange:(id)arg1{
	_forceEffectViewDockBackground=YES;
	%orig;
	_forceEffectViewDockBackground=NO;
}

-(void)layoutSubviews{
	%orig;
	[self updateDockBackgroundStyle];
	self.hidden=_dockMode==NONE;
}

%new
-(void)updateDockBackgroundStyle{
	id currentBackgroundView=MSHookIvar<id>(self, "_backgroundView");
	if([currentBackgroundView isMemberOfClass:[%c(SBWallpaperEffectView) class]] && [currentBackgroundView respondsToSelector:@selector(setStyle:)]){
		LWLog(@"Updating background style for iOS 7.1 or 8.1, _styleIndex=%i, style=%i", _styleIndex, STYLEFOR71);
		UIInterfaceOrientation orientation=[UIApplication sharedApplication].statusBarOrientation;
		if([%c(SBClockDataProvider) class] && (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)){
			//iOS 8.1 exclusive
			LWLog(@"orientation is landscape");
			[(SBWallpaperEffectView*)currentBackgroundView setStyle:_enabled?STYLEFOR81_LANDSCAPE:11]; //11=default for 7.1+
		}else{
			//iOS 7.1 and 8.1
			LWLog(@"orientation is portrait or we're on iOS7");
			[(SBWallpaperEffectView*)currentBackgroundView setStyle:_enabled?STYLEFOR71:11]; //11=default for 7.1+
		}
	}else if([currentBackgroundView isMemberOfClass:[%c(_SBDockBackgroundView) class]] && [currentBackgroundView respondsToSelector:@selector(setStyle:)]){
		LWLog(@"Updating background style for iOS 7.0");
		//iOS 7.0
		[(_SBDockBackgroundView*)currentBackgroundView setStyle:_enabled?STYLEFOR70:7/* 7=default for 7.0*/];
	}
	[self removeWhiteLine];
}

%new
-(void)removeWhiteLine{
	if(_enabled){
		LWLog(@"Removing annoying white line");
		SBHighlightView* highlightView=MSHookIvar<SBHighlightView*>(self, "_highlightView");
		
		if(_forcewhitelineremoval || _styleIndex==0){
			[highlightView removeFromSuperview];
			[highlightView setHidden:YES];
			[highlightView setAlpha:0];
		}
	}
}

%end

%hook SBDockIconListView

-(CGFloat)topIconInset{
	if(_dockMode != DEFAULT){
		switch(_dockMode){
			case NONESTRETCHED: return 200;
			case SMALLWITHLABELS: return _oniPad?24:19;
			case SMALLWITHOUTLABELS: return _oniPad?41:32;
			case SMALLSEATEDICONS: return _oniPad?48:36;
			case DEFAULTLOWEREDICONS: return _oniPad?38:33;
			case DEFAULTSEATEDICONS: return _oniPad?48:36;
		}
	}
	return %orig();
}

%end

%hook SBIconListPageControl

-(void)setBounds:(CGRect)bounds{
	if(_enabled && _shiftPageControl){
		CGFloat y=0;
		switch(_dockMode){
			case DEFAULT: y=_oniPad?0:-5; break;
			case DEFAULTLOWEREDICONS: y=_oniPad?0:-15; break;
			case DEFAULTSEATEDICONS: y=_oniPad?0:-17; break;
		}
		%orig(CGRectMake(bounds.origin.x, y, bounds.size.width, bounds.size.height));
	}else{
		%orig;
	}	
}

-(void)layoutSubviews{
	%orig;
	if(_enabled && _hidePageControl){
		self.hidden=YES;
	}
}

%end

%hook SpringBoard

-(void)applicationDidFinishLaunching:(UIApplication*)application{
	%orig;
	updateDockBackgroundView();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, settingsChanged, CFSTR("de.ng.DockShift.settingsChanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}

%end

%hook UIView

+(BOOL)_motionEffectsSupported{
	if(_forceEffectViewDockBackground){
		//we need this method to return true when SBDockView's initWithDockListView:... is executing to be able to style the dock background
		//see http://www.reddit.com/r/jailbreak/comments/2gd8of/update_dockshift_v152_vs_nomotion/ckiagym for further explanation
		return YES;
	}
	return %orig;
}

%end

%end


%group SpringBoard_iOS7

%hook SBDockView

-(CGFloat)heightForOrientation:(NSInteger)orientation{
	CGFloat r=%orig;
	if(_dockMode != DEFAULT){
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

%end

%end


%ctor {
	loadSettings();
	MSHookFunction(_UIAccessibilityEnhanceBackgroundContrast,
				   my_UIAccessibilityEnhanceBackgroundContrast,
				   &their_UIAccessibilityEnhanceBackgroundContrast);
	
	%init(SpringBoard_General);
	if(![%c(SBClockDataProvider) class]){
		//7.1
		%init(SpringBoard_iOS7);
	}
	
	LWLog(@"constructor is done");
}