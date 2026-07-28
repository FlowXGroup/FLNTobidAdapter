//
//  FLNCustomSplashAdapter.m
//  WindmillSample
//
//  加载超时：[WindMillConstant Timeout] → splashAd.timeout。
//

#import "FLNCustomSplashAdapter.h"
#import "FLNBiddingHelper.h"
#import <WindFoundation/WindFoundation.h>
#import <FLNAdSDK/FLNSplashAd.h>

@interface FLNCustomSplashAdapter () <FLNSplashAdDelegate>
@property (nonatomic, weak) id<AWMCustomSplashAdapterBridge> bridge;
@property (nonatomic, strong) FLNSplashAd *splashAd;
@property (nonatomic, assign) BOOL isReady;
@end

@implementation FLNCustomSplashAdapter

- (instancetype)initWithBridge:(id<AWMCustomSplashAdapterBridge>)bridge {
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
    self.splashAd = [[FLNSplashAd alloc] initWithPosId:parameter.placementId ?: placementId];
    self.splashAd.delegate = self;
    int fetchDelay = [[parameter.extra objectForKey:[WindMillConstant Timeout]] intValue];
    if (fetchDelay > 0) {
        self.splashAd.timeout = fetchDelay;
    }
    [self.splashAd loadAd];
}

- (void)showSplashAdInWindow:(UIWindow *)window parameter:(AWMParameter *)parameter {
    (void)parameter;
    UIWindow *targetWindow = window;
    if (!targetWindow) {
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (scene.activationState != UISceneActivationStateForegroundActive) {
                continue;
            }
            if (![scene isKindOfClass:[UIWindowScene class]]) {
                continue;
            }
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            for (UIWindow *w in windowScene.windows) {
                if (w.isKeyWindow) {
                    targetWindow = w;
                    break;
                }
            }
            if (!targetWindow) {
                targetWindow = windowScene.windows.firstObject;
            }
            if (targetWindow) {
                break;
            }
        }
    }
    if (targetWindow && [self.splashAd isReady]) {
        [self.splashAd showAdInWindow:targetWindow];
    } else {
        NSError *error = [NSError errorWithDomain:@"FLN" code:-1 userInfo:@{ NSLocalizedDescriptionKey: @"splash not ready" }];
        [self.bridge splashAdDidShowFailed:self error:error];
    }
}

- (void)didReceiveBidResult:(AWMMediaBidResult *)result {
    FLNApplyMediaBidResult(result, self.splashAd);
}

- (void)destory {
    self.splashAd = nil;
    self.isReady = NO;
}

#pragma mark - FLNSplashAdDelegate

- (void)splashAdDidLoad:(FLNSplashAd *)splashAd {
    WindmillLogDebug(@"FLN", @"%@", NSStringFromSelector(_cmd));
    NSString *price = [@([splashAd eCPM]) stringValue];
    [self.bridge splashAd:self didAdServerResponseWithExt:@{ [WindMillConstant ECPM]: price }];
    if ([splashAd isReady]) {
        self.isReady = YES;
        [self.bridge splashAdDidLoad:self];
    }
}

- (void)splashAdLoadFail:(FLNSplashAd *)splashAd error:(NSError *)error {
    WindmillLogDebug(@"FLN", @"%@", NSStringFromSelector(_cmd));
    self.isReady = NO;
    [self.bridge splashAd:self didLoadFailWithError:error ext:nil];
}

- (void)splashAdDidShow:(FLNSplashAd *)splashAd {
    WindmillLogDebug(@"FLN", @"%@", NSStringFromSelector(_cmd));
    self.isReady = NO;
    [self.bridge splashAdWillVisible:self];
}

- (void)splashAdShowFailed:(FLNSplashAd *)splashAd withError:(NSError *)error {
    WindmillLogDebug(@"FLN", @"%@", NSStringFromSelector(_cmd));
    [self.bridge splashAdDidShowFailed:self error:error];
}

- (void)splashAdClicked:(FLNSplashAd *)splashAd {
    WindmillLogDebug(@"FLN", @"%@", NSStringFromSelector(_cmd));
    [self.bridge splashAdDidClick:self];
}

- (void)splashAdClosed:(FLNSplashAd *)splashAd {
    WindmillLogDebug(@"FLN", @"%@", NSStringFromSelector(_cmd));
    self.splashAd = nil;
    [self.bridge splashAdDidClose:self];
}

- (void)splashAdSkip:(FLNSplashAd *)splashAd time:(NSInteger)time {
    WindmillLogDebug(@"FLN", @"%@ %ld", NSStringFromSelector(_cmd), (long)time);
    [self.bridge splashAdDidClickSkip:self];
}

@end
