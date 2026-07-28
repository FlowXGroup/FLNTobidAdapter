//
//  FLNNativeAdViewCreator.m
//  WindmillSample
//
//  AWMMediatedNativeAdViewCreator 实现：自渲染用 FLNUnifiedNativeAdView register；曝光/点击回传 bridge。
//

#import "FLNNativeAdViewCreator.h"
#import <FLNAdSDK/FLNUnifiedNativeAdDataObject.h>
#import <FLNAdSDK/FLNUnifiedNativeAdView.h>
#import <FLNAdSDK/FLNNativeExpressAdView.h>
#import <WindFoundation/WindFoundation.h>

@interface FLNNativeAdViewCreator () <FLNUnifiedNativeAdViewDelegate>
@property (nonatomic, weak) id<AWMCustomNativeAdapterBridge> bridge;
@property (nonatomic, weak) id<AWMCustomNativeAdapter> adapter;
@property (nonatomic, strong) FLNUnifiedNativeAdDataObject *dataObject;
@property (nonatomic, strong) FLNUnifiedNativeAdView *unifiedView;
@property (nonatomic, strong) FLNNativeExpressAdView *expressAdView;
@property (nonatomic, strong) UIImage *placeholderImage;
@end

@implementation FLNNativeAdViewCreator

@synthesize adLogoView = _adLogoView;
@synthesize dislikeBtn = _dislikeBtn;
@synthesize imageView = _imageView;
@synthesize imageViewArray = _imageViewArray;
@synthesize mediaView = _mediaView;

- (instancetype)initWithDataObject:(FLNUnifiedNativeAdDataObject *)dataObject
                            bridge:(id<AWMCustomNativeAdapterBridge>)bridge
                           adapter:(id<AWMCustomNativeAdapter>)adapter {
    self = [super init];
    if (self) {
        _dataObject = dataObject;
        _bridge = bridge;
        _adapter = adapter;
        _unifiedView = [[FLNUnifiedNativeAdView alloc] init];
        _unifiedView.delegate = self;
    }
    return self;
}

- (instancetype)initWithExpressAdView:(FLNNativeExpressAdView *)adView
                               bridge:(id<AWMCustomNativeAdapterBridge>)bridge
                              adapter:(id<AWMCustomNativeAdapter>)adapter {
    self = [super init];
    if (self) {
        _expressAdView = adView;
        _bridge = bridge;
        _adapter = adapter;
    }
    return self;
}

- (void)setRootViewController:(UIViewController *)viewController {
    self.unifiedView.viewController = viewController;
}

- (void)registerContainer:(UIView *)containerView withClickableViews:(NSArray<UIView *> *)clickableViews {
    if (!self.dataObject || ![self.dataObject isAdValid]) {
        return;
    }
    [self.unifiedView removeFromSuperview];
    [containerView addSubview:self.unifiedView];
    self.unifiedView.frame = containerView.bounds;
    self.unifiedView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.unifiedView registerDataObject:self.dataObject clickableViews:clickableViews];
}

- (void)refreshData {
    if (self.expressAdView) {
        return;
    }
    NSArray *urls = self.dataObject.imageUrl;
    if (urls.count == 1) {
        NSURL *u = [NSURL URLWithString:[urls.firstObject description]];
        [self.imageView sm_setImageWithURL:u placeholderImage:self.placeholderImage];
    } else if (urls.count >= 3) {
        [urls enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (idx >= self.imageViewArray.count) {
                *stop = YES;
                return;
            }
            NSURL *u = [NSURL URLWithString:[obj description]];
            [self.imageViewArray[idx] sm_setImageWithURL:u placeholderImage:self.placeholderImage];
        }];
    }
}

- (void)setPlaceholderImage:(UIImage *)placeholderImage {
    _placeholderImage = placeholderImage;
}

- (void)unregisterDataObject {
    [self.unifiedView unregisterDataObject];
}

#pragma mark - Getters

- (UIView *)adLogoView {
    if (!_adLogoView) {
        _adLogoView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _adLogoView;
}

- (UIButton *)dislikeBtn {
    if (!_dislikeBtn) {
        _dislikeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _dislikeBtn.hidden = YES;
    }
    return _dislikeBtn;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}


- (NSArray<UIImageView *> *)imageViewArray {
    if (self.dataObject.imageUrl.count < 3) {
        return nil;
    }
    if (!_imageViewArray) {
        NSMutableArray *arr = [NSMutableArray array];
        for (NSUInteger i = 0; i < 3; i++) {
            UIImageView *iv = [[UIImageView alloc] init];
            iv.contentMode = UIViewContentModeScaleAspectFill;
            iv.clipsToBounds = YES;
            [arr addObject:iv];
        }
        _imageViewArray = arr;
    }
    return _imageViewArray;
}

- (UIView *)mediaView {
    if (!_mediaView) {
        _mediaView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _mediaView;
}

#pragma mark - FLNUnifiedNativeAdViewDelegate

- (void)fln_unifiedNativeAdViewDidExpose:(FLNUnifiedNativeAdView *)unifiedNativeAdView {
    [self.bridge nativeAd:self.adapter didVisibleWithMediatedNativeAd:self.dataObject];
}

- (void)fln_unifiedNativeAdViewDidClick:(FLNUnifiedNativeAdView *)unifiedNativeAdView {
    [self.bridge nativeAd:self.adapter didClickWithMediatedNativeAd:self.dataObject];
}

- (void)fln_unifiedNativeAdDetailViewClosed:(FLNUnifiedNativeAdView *)unifiedNativeAdView {
    [self.bridge nativeAd:self.adapter didDismissFullScreenModalWithMediatedNativeAd:self.dataObject interactionType:WindMillInteractionTypeCustom];
}

- (void)fln_unifiedNativeAdDetailViewWillPresentScreen:(FLNUnifiedNativeAdView *)unifiedNativeAdView {
    [self.bridge nativeAd:self.adapter willPresentFullScreenModalWithMediatedNativeAd:self.dataObject];
}

@end
