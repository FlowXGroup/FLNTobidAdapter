//
//  FLNExpressRewardVideoAd.m
//  WindmillSample
//
//  FLNRewardAd 生命周期：didLoad → readyToPlay（此时 mediated 可展示）→ show → close。
//  超时/静音：extra 中 [WindMillConstant Timeout]、videoMuted。
//  发奖：didRewardEffective 映射为 WindMillRewardInfo 回传 bridge。
//

#import "FLNExpressRewardVideoAd.h"
#import "FLNBiddingHelper.h"
#import <WindMillSDK/WindMillSDK.h>
#import <WindFoundation/WindFoundation.h>
#import <FLNAdSDK/FLNRewardAd.h>

@interface FLNExpressRewardVideoAd () <FLNRewardAdDelegate>
@property (nonatomic, weak) id<AWMCustomRewardedVideoAdapterBridge> bridge;
@property (nonatomic, weak) id<AWMCustomRewardedVideoAdapter> adapter;
@property (nonatomic, strong) FLNRewardAd *rewardAd;
@property (nonatomic, assign) BOOL isReady;
@end

@implementation FLNExpressRewardVideoAd

- (instancetype)initWithBridge:(id<AWMCustomAdapterBridge>)bridge adapter:(id<AWMCustomAdapter>)adapter {
    self = [super init];
    if (self) {
        _bridge = (id<AWMCustomRewardedVideoAdapterBridge>)bridge;
        _adapter = (id<AWMCustomRewardedVideoAdapter>)adapter;
    }
    return self;
}

- (BOOL)mediatedAdStatus {
    return self.isReady;
}

- (void)loadAdWithPlacementId:(NSString *)placementId parameter:(AWMParameter *)parameter {
    self.isReady = NO;
    self.rewardAd = [[FLNRewardAd alloc] initWithPosId:parameter.placementId ?: placementId];
    self.rewardAd.delegate = self;
    int fetchDelay = [[parameter.extra objectForKey:[WindMillConstant Timeout]] intValue];
    if (fetchDelay > 0) {
        self.rewardAd.timeout = fetchDelay;
    }
    NSNumber *muted = [parameter.extra objectForKey:@"videoMuted"];
    if (muted) {
        self.rewardAd.videoMuted = muted.boolValue;
    }
    [self.rewardAd loadAd];
}

- (void)showAdFromRootViewController:(UIViewController *)viewController parameter:(AWMParameter *)parameter {
    (void)parameter;
    if ([self.rewardAd isReady]) {
        [self.rewardAd presentAdFromRootViewController:viewController];
    }
}

- (void)didReceiveBidResult:(AWMMediaBidResult *)result {
    FLNApplyMediaBidResult(result, self.rewardAd);
}

#pragma mark - FLNRewardAdDelegate

- (void)rewardVideoAdDidLoad:(FLNRewardAd *)rewardedAd {
    WindmillLogDebug(@"FLN", @"%@", NSStringFromSelector(_cmd));
    NSString *price = [@([rewardedAd eCPM]) stringValue];
    [self.bridge rewardedVideoAd:self.adapter didAdServerResponseWithExt:@{ [WindMillConstant ECPM]: price }];
}

- (void)rewardVideoAd:(FLNRewardAd *)rewardedAd didFailWithError:(NSError *)error {
    WindmillLogDebug(@"FLN", @"%@", NSStringFromSelector(_cmd));
    self.isReady = NO;
    [self.bridge rewardedVideoAd:self.adapter didLoadFailWithError:error ext:nil];
}

- (void)rewardVideoAdReadyToPlay:(FLNRewardAd *)rewardedAd {
    WindmillLogDebug(@"FLN", @"%@", NSStringFromSelector(_cmd));
    self.isReady = YES;
    [self.bridge rewardedVideoAdDidLoad:self.adapter];
}

- (void)rewardVideoAdDidShow:(FLNRewardAd *)rewardedAd {
    WindmillLogDebug(@"FLN", @"%@", NSStringFromSelector(_cmd));
    self.isReady = NO;
    [self.bridge rewardedVideoAdDidVisible:self.adapter];
}

- (void)rewardVideoAdShowFailed:(FLNRewardAd *)rewardedAd error:(NSError *)error {
    WindmillLogDebug(@"FLN", @"%@", NSStringFromSelector(_cmd));
    [self.bridge rewardedVideoAdDidShowFailed:self.adapter error:error];
}

- (void)rewardVideoAdDidClose:(FLNRewardAd *)rewardedAd {
    WindmillLogDebug(@"FLN", @"%@", NSStringFromSelector(_cmd));
    self.rewardAd = nil;
    [self.bridge rewardedVideoAdDidClose:self.adapter];
}

- (void)rewardVideoAdDidClicked:(FLNRewardAd *)rewardedAd {
    WindmillLogDebug(@"FLN", @"%@", NSStringFromSelector(_cmd));
    [self.bridge rewardedVideoAdDidClick:self.adapter];
}

- (void)rewardVideoAdDidPlayStart:(FLNRewardAd *)rewardedAd {
    WindmillLogDebug(@"FLN", @"%@", NSStringFromSelector(_cmd));
    (void)rewardedAd;
}

- (void)rewardVideoAdDidPlayFinish:(FLNRewardAd *)rewardedAd {
    WindmillLogDebug(@"FLN", @"%@", NSStringFromSelector(_cmd));
    [self.bridge rewardedVideoAd:self.adapter didPlayFinishWithError:nil];
}

- (void)rewardVideoAdDidRewardEffective:(FLNRewardAd *)rewardedAd info:(NSDictionary *)info {
    WindmillLogDebug(@"FLN", @"%@", NSStringFromSelector(_cmd));
    (void)rewardedAd;
    WindMillRewardInfo *rewardInfo = [[WindMillRewardInfo alloc] initWithIsCompeltedView:YES];
    [self.bridge rewardedVideoAd:self.adapter didRewardSuccessWithInfo:rewardInfo];
}

@end
