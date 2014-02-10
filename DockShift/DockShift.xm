#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

#define STYLEFOR70 [_stylesFor70[_styleIndex] intValue]
#define STYLEFOR71 [_stylesFor71[_styleIndex] intValue]

@interface SBDockView : UIView
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

static NSArray* _stylesFor70=@[@9,
                               @16,@7,@6,@17,@10,@14,
                               @8,@11,
                               @12,@5,@3];
static NSArray* _stylesFor71=@[@12,
                               @19,@9,@8,@20,@13,@17,
                               @10,@14,
                               @15,@6,@4];

enum DOCKMODE{
	DEFAULT=0,
	SMALLWITHLABELS,
	SMALLWITHOUTLABELS,
	SMALLSEATEDICONS,
	DEFAULTLOWEREDICONS,
	DEFAULTSEATEDICONS
};

static void updateDockBackgroundView();

static const BOOL _oniPad=UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;

static BOOL _enabled=YES;
static NSInteger _dockMode=DEFAULT;
static BOOL _shiftPageControl=NO;
static BOOL _forcewhitelineremoval=NO;
static NSInteger _styleIndex=3;

static void loadSettings(){
	NSDictionary *settings=[[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/de.ng.DockShift.plist"];
	
	if (!settings) {
		return;
	}
	
	id temp=[settings objectForKey:@"style"];
	_styleIndex=temp ? [temp integerValue] : 2;
	
	if(_styleIndex < 0 || _styleIndex > 11){
		_styleIndex=3;
	}
    
	temp=[settings objectForKey:@"enabled"];
	_enabled=temp ? [temp boolValue] : NO;
    
	temp=[settings objectForKey:@"dockmode"];
	_dockMode=temp ? [temp integerValue] : 0;
    
	temp=[settings objectForKey:@"shiftedpagecontrol"];
	_shiftPageControl=temp ? [temp boolValue] && _styleIndex==0 : NO;
    
	temp=[settings objectForKey:@"forcewhitelineremoval"];
	_forcewhitelineremoval=temp ? [temp boolValue] : NO;
    
	[temp release];
	[settings release];
}

static void settingsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){
	loadSettings();
	updateDockBackgroundView();
}

static void updateDockBackgroundView(){
	[[[[[%c(SBIconController) sharedInstance] _rootFolderController] contentView] dockView] updateDockBackgroundStyle];
}

%hook SBDockView

-(id)initWithDockListView:(id)dockListView forSnapshot:(BOOL)snapshot{
	id r=%orig;
	[self removeWhiteLine];
	return r;
}

-(void)layoutSubviews{
	%orig;
	[self updateDockBackgroundStyle];
}

%new
-(void)updateDockBackgroundStyle{
	id currentBackgroundView=MSHookIvar<id>(self, "_backgroundView");
	if([currentBackgroundView isMemberOfClass:[%c(SBWallpaperEffectView) class]] && [currentBackgroundView respondsToSelector:@selector(setStyle:)]){
		//iOS 7.1
		[(SBWallpaperEffectView*)currentBackgroundView setStyle:_enabled?STYLEFOR71:9/* =default for 7.1*/];
	}else if([currentBackgroundView isMemberOfClass:[%c(_SBDockBackgroundView) class]] && [currentBackgroundView respondsToSelector:@selector(setStyle:)]){
		//iOS 7.0
		[(_SBDockBackgroundView*)currentBackgroundView setStyle:_enabled?STYLEFOR70:7/* =default for 7.0*/];
	}
	[self removeWhiteLine];
}

%new
-(void)removeWhiteLine{
    if(_enabled){
        SBHighlightView* highlightView=MSHookIvar<SBHighlightView*>(self, "_highlightView");
        CGFloat alpha=1;
        BOOL hiddenEnabled=NO;
        
        if(_forcewhitelineremoval || _styleIndex==0){
            alpha=0;
            hiddenEnabled=YES;
        }
        
        if([highlightView respondsToSelector:@selector(setHidden:)]){
            [highlightView setHidden:hiddenEnabled];
            [highlightView setAlpha:alpha];
        }
    }
}

-(CGFloat)heightForOrientation:(NSInteger)orientation{
	CGFloat r=%orig;
	if(_dockMode != DEFAULT){
		if(_dockMode==SMALLWITHLABELS){
			r=_oniPad?110:86;
		}else if(_dockMode==SMALLWITHOUTLABELS){
			r=_oniPad?90:69;
		}else if(_dockMode==SMALLSEATEDICONS){
			r=_oniPad?76:60;
		}
	}
	return r;
}

%end

%hook SBDockIconListView

-(CGFloat)topIconInset{
	if(_dockMode != DEFAULT){
		switch(_dockMode){
			case SMALLWITHLABELS: return _oniPad?22:18;
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
    CGFloat y=0;
    if(_shiftPageControl){
        switch(_dockMode){
            case DEFAULT: y=_oniPad?0:-5; break;
			case DEFAULTLOWEREDICONS: y=_oniPad?0:-15; break;
			case DEFAULTSEATEDICONS: y=_oniPad?0:-17; break;
        }
    }
    NSLog(@"luke: %li", (long)_dockMode);
    NSLog(@"luke: %f", y);
    
	%orig(CGRectMake(bounds.origin.x,
                     y,
                     bounds.size.width,
                     bounds.size.height));
}

%new
-(void)shiftDock{
	CGRect bounds=self.bounds;
	[self setBounds:CGRectMake(bounds.origin.x,
                               bounds.origin.y,
                               bounds.size.width,
                               bounds.size.height)];
}

%end

%hook SpringBoard

-(void)applicationDidFinishLaunching:(UIApplication*)application{
	%orig;
	updateDockBackgroundView();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, settingsChanged, CFSTR("de.ng.DockShift.settingsChanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}

%end

%ctor {
	loadSettings();
}
