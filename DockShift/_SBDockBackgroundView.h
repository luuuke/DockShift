@class UIImage, SBWallpaperEffectView;

@interface _SBDockBackgroundView : UIView {
	UIImage* _maskImage;
	CGFloat _maskHeight;
	SBWallpaperEffectView* _maskedView;
	SBWallpaperEffectView* _unmaskedView;
}
-(void)setStyle:(NSInteger)style;
-(void)layoutSubviews;
-(void)dealloc;
-(id)initWithMaskImage:(id)maskImage;
@end

