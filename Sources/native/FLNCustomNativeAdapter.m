//
//  FLNCustomNativeAdapter.m
//  WindmillSample
//
//  templateType：1 = FLN 自渲染（FLNUnifiedNativeAdsManager），其他 = 模板（FLNToBidNativeExpressAdManager）。
//  竞价结果、mediatedAdStatus 透传给当前子 manager。
//

#import "FLNCustomNativeAdapter.h"
#import "FLNCustomAdProtocol.h"
#import "FLNUnifiedNativeAdsManager.h"
#import "FLNToBidNativeExpressAdManager.h"
#import <WindFoundation/WindFoundation.h>

@interface FLNCustomNativeAdapter ()
@property (nonatomic, weak) id<AWMCustomNativeAdapterBridge> bridge;
@property (nonatomic, strong) id<FLNCustomAdProtocol> nativeAdManager;
@end

@implementation FLNCustomNativeAdapter

- (instancetype)initWithBridge:(id<AWMCustomNativeAdapterBridge>)bridge {
    self = [super init];
    if (self) {
        _bridge = bridge;
    }
    return self;
}

- (BOOL)mediatedAdStatus {
    if ([self.nativeAdManager respondsToSelector:@selector(mediatedAdStatus)]) {
        return [self.nativeAdManager mediatedAdStatus];
    }
    return NO;
}

- (void)loadAdWithPlacementId:(NSString *)placementId adSize:(CGSize)size parameter:(AWMParameter *)parameter {
    // 与 CSJ 等 Demo 一致：由后台策略 customInfo 下发，非代码写死。
    int templateType = [[parameter.customInfo objectForKey:@"templateType"] intValue];
    if (templateType == 1) {
        self.nativeAdManager = [[FLNUnifiedNativeAdsManager alloc] initWithBridge:self.bridge adapter:self];
    } else {
        self.nativeAdManager = [[FLNToBidNativeExpressAdManager alloc] initWithBridge:self.bridge adapter:self];
    }
    [self.nativeAdManager loadAdWithPlacementId:placementId adSize:size parameter:parameter];
}

- (void)didReceiveBidResult:(AWMMediaBidResult *)result {
    [self.nativeAdManager didReceiveBidResult:result];
}

@end
