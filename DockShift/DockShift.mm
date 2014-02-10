#line 1 "/Users/luke/Developer/DockShift/DockShift/DockShift.xm"
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

#include <logos/logos.h>
#include <substrate.h>
@class SBWallpaperEffectView; @class SBDockView; @class SBIconController; @class SBDockIconListView; @class SpringBoard; @class _SBDockBackgroundView; @class SBIconListPageControl; 
static id (*_logos_orig$_ungrouped$SBDockView$initWithDockListView$forSnapshot$)(SBDockView*, SEL, id, BOOL); static id _logos_method$_ungrouped$SBDockView$initWithDockListView$forSnapshot$(SBDockView*, SEL, id, BOOL); static void (*_logos_orig$_ungrouped$SBDockView$layoutSubviews)(SBDockView*, SEL); static void _logos_method$_ungrouped$SBDockView$layoutSubviews(SBDockView*, SEL); static void _logos_method$_ungrouped$SBDockView$updateDockBackgroundStyle(SBDockView*, SEL); static void _logos_method$_ungrouped$SBDockView$removeWhiteLine(SBDockView*, SEL); static CGFloat (*_logos_orig$_ungrouped$SBDockView$heightForOrientation$)(SBDockView*, SEL, NSInteger); static CGFloat _logos_method$_ungrouped$SBDockView$heightForOrientation$(SBDockView*, SEL, NSInteger); static CGFloat (*_logos_orig$_ungrouped$SBDockIconListView$topIconInset)(SBDockIconListView*, SEL); static CGFloat _logos_method$_ungrouped$SBDockIconListView$topIconInset(SBDockIconListView*, SEL); static void (*_logos_orig$_ungrouped$SBIconListPageControl$setBounds$)(SBIconListPageControl*, SEL, CGRect); static void _logos_method$_ungrouped$SBIconListPageControl$setBounds$(SBIconListPageControl*, SEL, CGRect); static void _logos_method$_ungrouped$SBIconListPageControl$shiftDock(SBIconListPageControl*, SEL); static void (*_logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$)(SpringBoard*, SEL, UIApplication*); static void _logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$(SpringBoard*, SEL, UIApplication*); 
static __inline__ __attribute__((always_inline)) Class _logos_static_class_lookup$SBWallpaperEffectView(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBWallpaperEffectView"); } return _klass; }static __inline__ __attribute__((always_inline)) Class _logos_static_class_lookup$SBIconController(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBIconController"); } return _klass; }static __inline__ __attribute__((always_inline)) Class _logos_static_class_lookup$_SBDockBackgroundView(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("_SBDockBackgroundView"); } return _klass; }
#line 104 "/Users/luke/Developer/DockShift/DockShift/DockShift.xm"
static void updateDockBackgroundView(){
	[[[[[_logos_static_class_lookup$SBIconController() sharedInstance] _rootFolderController] contentView] dockView] updateDockBackgroundStyle];
}



static id _logos_method$_ungrouped$SBDockView$initWithDockListView$forSnapshot$(SBDockView* self, SEL _cmd, id dockListView, BOOL snapshot){
	id r=_logos_orig$_ungrouped$SBDockView$initWithDockListView$forSnapshot$(self, _cmd, dockListView, snapshot);
	[self removeWhiteLine];
	return r;
}

static void _logos_method$_ungrouped$SBDockView$layoutSubviews(SBDockView* self, SEL _cmd){
	_logos_orig$_ungrouped$SBDockView$layoutSubviews(self, _cmd);
	[self updateDockBackgroundStyle];
}


static void _logos_method$_ungrouped$SBDockView$updateDockBackgroundStyle(SBDockView* self, SEL _cmd){
	id currentBackgroundView=MSHookIvar<id>(self, "_backgroundView");
	if([currentBackgroundView isMemberOfClass:[_logos_static_class_lookup$SBWallpaperEffectView() class]] && [currentBackgroundView respondsToSelector:@selector(setStyle:)]){
		
		[(SBWallpaperEffectView*)currentBackgroundView setStyle:_enabled?STYLEFOR71:9];
	}else if([currentBackgroundView isMemberOfClass:[_logos_static_class_lookup$_SBDockBackgroundView() class]] && [currentBackgroundView respondsToSelector:@selector(setStyle:)]){
		
		[(_SBDockBackgroundView*)currentBackgroundView setStyle:_enabled?STYLEFOR70:7];
	}
	[self removeWhiteLine];
}


static void _logos_method$_ungrouped$SBDockView$removeWhiteLine(SBDockView* self, SEL _cmd){
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

static CGFloat _logos_method$_ungrouped$SBDockView$heightForOrientation$(SBDockView* self, SEL _cmd, NSInteger orientation){
	CGFloat r=_logos_orig$_ungrouped$SBDockView$heightForOrientation$(self, _cmd, orientation);
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





static CGFloat _logos_method$_ungrouped$SBDockIconListView$topIconInset(SBDockIconListView* self, SEL _cmd){
	if(_dockMode != DEFAULT){
		switch(_dockMode){
			case SMALLWITHLABELS: return _oniPad?22:18;
			case SMALLWITHOUTLABELS: return _oniPad?41:32;
			case SMALLSEATEDICONS: return _oniPad?48:36;
			case DEFAULTLOWEREDICONS: return _oniPad?38:33;
			case DEFAULTSEATEDICONS: return _oniPad?48:36;
		}
	}
	return _logos_orig$_ungrouped$SBDockIconListView$topIconInset(self, _cmd);
}





static void _logos_method$_ungrouped$SBIconListPageControl$setBounds$(SBIconListPageControl* self, SEL _cmd, CGRect bounds){
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
    



	_logos_orig$_ungrouped$SBIconListPageControl$setBounds$(self, _cmd, CGRectMake(bounds.origin.x, y, bounds.size.width, bounds.size.height));
}


static void _logos_method$_ungrouped$SBIconListPageControl$shiftDock(SBIconListPageControl* self, SEL _cmd){
	CGRect bounds=self.bounds;
	[self setBounds:CGRectMake(bounds.origin.x,
                               bounds.origin.y,
                               bounds.size.width,
                               bounds.size.height)];
}





static void _logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$(SpringBoard* self, SEL _cmd, UIApplication* application){
	_logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$(self, _cmd, application);
	updateDockBackgroundView();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, settingsChanged, CFSTR("de.ng.DockShift.settingsChanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}



static __attribute__((constructor)) void _logosLocalCtor_986c81e8() {
	loadSettings();
}
static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SBDockView = objc_getClass("SBDockView"); MSHookMessageEx(_logos_class$_ungrouped$SBDockView, @selector(initWithDockListView:forSnapshot:), (IMP)&_logos_method$_ungrouped$SBDockView$initWithDockListView$forSnapshot$, (IMP*)&_logos_orig$_ungrouped$SBDockView$initWithDockListView$forSnapshot$);MSHookMessageEx(_logos_class$_ungrouped$SBDockView, @selector(layoutSubviews), (IMP)&_logos_method$_ungrouped$SBDockView$layoutSubviews, (IMP*)&_logos_orig$_ungrouped$SBDockView$layoutSubviews);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SBDockView, @selector(updateDockBackgroundStyle), (IMP)&_logos_method$_ungrouped$SBDockView$updateDockBackgroundStyle, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SBDockView, @selector(removeWhiteLine), (IMP)&_logos_method$_ungrouped$SBDockView$removeWhiteLine, _typeEncoding); }MSHookMessageEx(_logos_class$_ungrouped$SBDockView, @selector(heightForOrientation:), (IMP)&_logos_method$_ungrouped$SBDockView$heightForOrientation$, (IMP*)&_logos_orig$_ungrouped$SBDockView$heightForOrientation$);Class _logos_class$_ungrouped$SBDockIconListView = objc_getClass("SBDockIconListView"); MSHookMessageEx(_logos_class$_ungrouped$SBDockIconListView, @selector(topIconInset), (IMP)&_logos_method$_ungrouped$SBDockIconListView$topIconInset, (IMP*)&_logos_orig$_ungrouped$SBDockIconListView$topIconInset);Class _logos_class$_ungrouped$SBIconListPageControl = objc_getClass("SBIconListPageControl"); MSHookMessageEx(_logos_class$_ungrouped$SBIconListPageControl, @selector(setBounds:), (IMP)&_logos_method$_ungrouped$SBIconListPageControl$setBounds$, (IMP*)&_logos_orig$_ungrouped$SBIconListPageControl$setBounds$);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SBIconListPageControl, @selector(shiftDock), (IMP)&_logos_method$_ungrouped$SBIconListPageControl$shiftDock, _typeEncoding); }Class _logos_class$_ungrouped$SpringBoard = objc_getClass("SpringBoard"); MSHookMessageEx(_logos_class$_ungrouped$SpringBoard, @selector(applicationDidFinishLaunching:), (IMP)&_logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$, (IMP*)&_logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$);} }
#line 230 "/Users/luke/Developer/DockShift/DockShift/DockShift.xm"
