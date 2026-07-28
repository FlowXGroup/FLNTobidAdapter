//
//  FLNToBidNativeExpressAdManager.m
//  WindmillSample
//
//  FLN 模板原生：渲染成功后需调 WindMill bridge 的 renderSuccessWithExpressView，与 CSJ 等行为一致。
//

#import "FLNToBidNativeExpressAdManager.h"
#import "FLNNativeAdViewCreator.h"
#import "FLNBiddingHelper.h"
#import <WindFoundation/WindFoundation.h>
#import <FLNAdSDK/FLNNativeExpressAd.h>
#import <FLNAdSDK/FLNNativeExpressAdView.h>

@interface FLNExpressNativeAdDataStub : NSObject <AWMMediatedNativeAdData>
@end

@implementation FLNExpressNativeAdDataStub
@synthesize title, desc, iconUrl, callToAction, rating, imageUrlList, adMode, adType, interactionType, networkId, videoCoverImage, videoUrl, imageModelList;
- (instancetype)init {
    self = [super init];
    if (self) {
        self.adMode = AWMMediatedNativeAdModeNativeExpress;
        self.adType = AWMNativeAdSlotAdTypeFeed;
        self.interactionType = AWMNativeAdInteractionTypeCustorm;
        self.networkId = 0;
    }
    return self;
}
@end

@interface FLNToBidNativeExpressAdManager () <FLNNativeExpressAdDelegate>
@property (nonatomic, weak) id<AWMCustomNativeAdapterBridge> bridge;
@property (nonatomic, weak) id<AWMCustomNativeAdapter> adapter;
@property (nonatomic, strong) FLNNativeExpressAd *expressAd;
@property (nonatomic, strong) NSArray<FLNNativeExpressAdView *> *adViews;
@end

@implementation FLNToBidNativeExpressAdManager

- (instancetype)initWithBridge:(id<AWMCustomAdapterBridge>)bridge adapter:(id<AWMCustomAdapter>)adapter {
    self = [super init];
    if (self) {
        _bridge = (id<AWMCustomNativeAdapterBridge>)bridge;
        _adapter = (id<AWMCustomNativeAdapter>)adapter;
    }
    return self;
}

- (BOOL)mediatedAdStatus {
    return self.adViews.count > 0;
}

- (void)loadAdWithPlacementId:(NSString *)placementId adSize:(CGSize)size parameter:(AWMParameter *)parameter {
    self.adViews = nil;
    CGFloat w = size.width > 0 ? size.width : [UIScreen mainScreen].bounds.size.width;
    self.expressAd = [[FLNNativeExpressAd alloc] initWithPosId:parameter.placementId ?: placementId width:w];
    self.expressAd.delegate = self;
    int fetchDelay = [[parameter.extra objectForKey:[WindMillConstant Timeout]] intValue];
    if (fetchDelay > 0) {
        self.expressAd.timeout = fetchDelay;
    }
    NSInteger count = 1;
    if (!parameter.isHeaderBidding) {
        count = (NSInteger)[[parameter.extra objectForKey:[WindMillConstant LoadAdCount]] integerValue];
        if (count <= 0) {
            count = 1;
        }
    }
    [self.expressAd loadAd:count];
}

- (void)didReceiveBidResult:(AWMMediaBidResult *)result {
    FLNApplyMediaBidResult(result, self.expressAd);
    self.adViews = nil;
}

#pragma mark - FLNNativeExpressAdDelegate

- (void)nativeExpressAdDidLoad:(FLNNativeExpressAd *)nativeExpressAd {
    WindmillLogDebug(@"FLN", @"%@", NSStringFromSelector(_cmd));
    (void)nativeExpressAd;
}

- (void)nativeExpressAdFailToLoad:(FLNNativeExpressAd *)nativeExpressAd error:(NSError *)error {
    WindmillLogDebug(@"FLN", @"%@", NSStringFromSelector(_cmd));
    self.adViews = nil;
    [self.bridge nativeAd:self.adapter didLoadFailWithError:error];
}

- (void)nativeExpressAdViewRenderSuccess:(FLNNativeExpressAd *)nativeExpressAd
                     nativeExpressAdView:(NSArray<__kindof FLNNativeExpressAdView *> *)nativeExpressAdViews {
    WindmillLogDebug(@"FLN", @"%@", NSStringFromSelector(_cmd));
    self.adViews = nativeExpressAdViews;
    FLNNativeExpressAdView *first = nativeExpressAdViews.firstObject;
    NSString *price = [@([first eCPM]) stringValue];
    [self.bridge nativeAd:self.adapter didAdServerResponseWithExt:@{ [WindMillConstant ECPM]: price }];
    NSMutableArray *adArray = [NSMutableArray array];
    for (FLNNativeExpressAdView *adView in nativeExpressAdViews) {
        FLNExpressNativeAdDataStub *data = [[FLNExpressNativeAdDataStub alloc] init];
        FLNNativeAdViewCreator *viewCreator = [[FLNNativeAdViewCreator alloc] initWithExpressAdView:adView bridge:self.bridge adapter:self.adapter];
        AWMMediatedNativeAd *m = [[AWMMediatedNativeAd alloc] initWithData:data viewCreator:viewCreator originAd:adView];
        m.view = adView;
        [adArray addObject:m];
    }
    [self.bridge nativeAd:self.adapter didLoadWithNativeAds:adArray];
    for (FLNNativeExpressAdView *adView in nativeExpressAdViews) {
        [self.bridge nativeAd:self.adapter renderSuccessWithExpressView:adView];
    }
}

- (void)nativeExpressAdViewRenderFail:(FLNNativeExpressAd *)nativeExpressAd error:(NSError *)error {
    WindmillLogDebug(@"FLN", @"%@", NSStringFromSelector(_cmd));
    FLNNativeExpressAdView *failedView = self.adViews.firstObject;
    self.adViews = nil;
    if (failedView) {
        [self.bridge nativeAd:self.adapter renderFailWithExpressView:failedView andError:error];
    } else {
        [self.bridge nativeAd:self.adapter didLoadFailWithError:error];
    }
}

- (void)nativeExpressAdViewDidShow:(FLNNativeExpressAd *)nativeExpressAd
               nativeExpressAdView:(FLNNativeExpressAdView *)nativeExpressAdView {
    WindmillLogDebug(@"FLN", @"%@", NSStringFromSelector(_cmd));
    [self.bridge nativeAd:self.adapter didVisibleWithMediatedNativeAd:nativeExpressAdView];
}

- (void)nativeExpressAdViewClicked:(FLNNativeExpressAd *)nativeExpressAd
               nativeExpressAdView:(FLNNativeExpressAdView *)nativeExpressAdView {
    WindmillLogDebug(@"FLN", @"%@", NSStringFromSelector(_cmd));
    [self.bridge nativeAd:self.adapter didClickWithMediatedNativeAd:nativeExpressAdView];
}

- (void)nativeExpressAdViewClosed:(FLNNativeExpressAd *)nativeExpressAd
              nativeExpressAdView:(FLNNativeExpressAdView *)nativeExpressAdView {
    WindmillLogDebug(@"FLN", @"%@", NSStringFromSelector(_cmd));
    [self.bridge nativeAd:self.adapter didClose:nativeExpressAdView closeReasons:@[]];
}

@end
