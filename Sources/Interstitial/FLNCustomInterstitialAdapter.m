//
//  FLNCustomInterstitialAdapter.m
//  WindmillSample
//
//  isReady：仅在 load 成功且 FLN isReady 时为 YES；展示后开始消耗，与 delegate 同步清空。
//

#import "FLNCustomInterstitialAdapter.h"
#import "FLNBiddingHelper.h"
#import <WindFoundation/WindFoundation.h>
#import <FLNAdSDK/FLNInterstitialAd.h>

@interface FLNCustomInterstitialAdapter () <FLNInterstitialAdDelegate>
@property (nonatomic, weak) id<AWMCustomInterstitialAdapterBridge> bridge;
@property (nonatomic, strong) FLNInterstitialAd *interstitialAd;
@property (nonatomic, assign) BOOL isReady;
@end

@implementation FLNCustomInterstitialAdapter

- (instancetype)initWithBridge:(id<AWMCustomInterstitialAdapterBridge>)bridge {
    self = [super init];
    if (self) {
        _bridge = bridge;
    }
    return self;
}

- (BOOL)mediatedAdStatus {
    return self.isReady;
}

- (void)loadAdWithPlacementId:(NSString *)placementId parameter:(AWMParameter *)parameter {
    self.isReady = NO;
    self.interstitialAd = [[FLNInterstitialAd alloc] initWithPosId:parameter.placementId ?: placementId];
    self.interstitialAd.delegate = self;
    [self.interstitialAd loadAd];
}

- (void)showAdFromRootViewController:(UIViewController *)viewController parameter:(AWMParameter *)parameter {
    (void)parameter;
    if ([self.interstitialAd isReady]) {
        [self.interstitialAd presentAdFromRootViewController:viewController];
    }
}

- (void)didReceiveBidResult:(AWMMediaBidResult *)result {
    FLNApplyMediaBidResult(result, self.interstitialAd);
}

- (void)destory {
    self.interstitialAd = nil;
    self.isReady = NO;
}

#pragma mark - FLNInterstitialAdDelegate

- (void)interstitialAdDidLoad:(FLNInterstitialAd *)interstitialAd {
    WindmillLogDebug(@"FLN", @"%@", NSStringFromSelector(_cmd));
    NSString *price = [@([interstitialAd eCPM]) stringValue];
    [self.bridge interstitialAd:self didAdServerResponseWithExt:@{ [WindMillConstant ECPM]: price }];
    if ([interstitialAd isReady]) {
        self.isReady = YES;
        [self.bridge interstitialAdDidLoad:self];
    }
}

- (void)interstitialAd:(FLNInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
    WindmillLogDebug(@"FLN", @"%@", NSStringFromSelector(_cmd));
    self.isReady = NO;
    [self.bridge interstitialAd:self didLoadFailWithError:error ext:nil];
}

- (void)interstitialAdDidShow:(FLNInterstitialAd *)interstitial {
    WindmillLogDebug(@"FLN", @"%@", NSStringFromSelector(_cmd));
    self.isReady = NO;
    [self.bridge interstitialAdDidVisible:self];
}

- (void)interstitialAdShowFailed:(FLNInterstitialAd *)interstitialAd error:(NSError *)error {
    WindmillLogDebug(@"FLN", @"%@", NSStringFromSelector(_cmd));
    [self.bridge interstitialAdDidShowFailed:self error:error];
}

- (void)interstitialAdDidClose:(FLNInterstitialAd *)interstitialAd {
    WindmillLogDebug(@"FLN", @"%@", NSStringFromSelector(_cmd));
    self.interstitialAd = nil;
    [self.bridge interstitialAdDidClose:self];
}

- (void)interstitialAdDidClicked:(FLNInterstitialAd *)interstitialAd {
    WindmillLogDebug(@"FLN", @"%@", NSStringFromSelector(_cmd));
    [self.bridge interstitialAdDidClick:self];
}

- (void)interstitialAdDidDismissScreen:(FLNInterstitialAd *)interstitialAd {
    WindmillLogDebug(@"FLN", @"%@", NSStringFromSelector(_cmd));
    (void)interstitialAd;
}

@end
