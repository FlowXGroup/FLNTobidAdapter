//
//  FLNUnifiedNativeAdsManager.m
//  WindmillSample
//
//  FLN 自渲染原生：FLNUnifiedNativeAd 拉取后封装为 AWMMediatedNativeAd（FLNUnifiedNativeAdData + FLNNativeAdViewCreator）。
//

#import "FLNUnifiedNativeAdsManager.h"
#import "FLNUnifiedNativeAdData.h"
#import "FLNNativeAdViewCreator.h"
#import "FLNBiddingHelper.h"
#import <WindFoundation/WindFoundation.h>
#import <FLNAdSDK/FLNUnifiedNativeAd.h>
#import <FLNAdSDK/FLNUnifiedNativeAdDataObject.h>

@interface FLNUnifiedNativeAdsManager () <FLNUnifiedNativeAdDelegate>
@property (nonatomic, weak) id<AWMCustomNativeAdapterBridge> bridge;
@property (nonatomic, weak) id<AWMCustomNativeAdapter> adapter;
@property (nonatomic, strong) FLNUnifiedNativeAd *unifiedNativeAd;
@property (nonatomic, strong) NSArray<FLNUnifiedNativeAdDataObject *> *loadedObjects;
@property (nonatomic, assign) BOOL loaded;
@end

@implementation FLNUnifiedNativeAdsManager

- (instancetype)initWithBridge:(id<AWMCustomAdapterBridge>)bridge adapter:(id<AWMCustomAdapter>)adapter {
    self = [super init];
    if (self) {
        _bridge = (id<AWMCustomNativeAdapterBridge>)bridge;
        _adapter = (id<AWMCustomNativeAdapter>)adapter;
    }
    return self;
}

- (BOOL)mediatedAdStatus {
    return self.loaded;
}

- (void)loadAdWithPlacementId:(NSString *)placementId adSize:(CGSize)size parameter:(AWMParameter *)parameter {
    (void)size;
    self.loaded = NO;
    self.loadedObjects = nil;
    self.unifiedNativeAd = [[FLNUnifiedNativeAd alloc] initWithPosId:parameter.placementId ?: placementId];
    self.unifiedNativeAd.delegate = self;
    [self.unifiedNativeAd loadAd];
}

- (void)didReceiveBidResult:(AWMMediaBidResult *)result {
    [self.loadedObjects enumerateObjectsUsingBlock:^(FLNUnifiedNativeAdDataObject *obj, NSUInteger idx, BOOL *stop) {
        FLNApplyMediaBidResult(result, obj);
    }];
    self.loadedObjects = nil;
}

#pragma mark - FLNUnifiedNativeAdDelegate

- (void)fln_unifiedNativeAdLoaded:(NSArray<FLNUnifiedNativeAdDataObject *> *)unifiedNativeAdDataObjects error:(NSError *)error {
    if (error || unifiedNativeAdDataObjects.count == 0) {
        WindmillLogDebug(@"FLN", @"%@", NSStringFromSelector(_cmd));
        self.loadedObjects = nil;
        [self.bridge nativeAd:self.adapter didLoadFailWithError:error ?: [NSError errorWithDomain:@"FLN" code:-2 userInfo:nil]];
        return;
    }
    WindmillLogDebug(@"FLN", @"%@", NSStringFromSelector(_cmd));
    self.loadedObjects = unifiedNativeAdDataObjects;
    FLNUnifiedNativeAdDataObject *first = unifiedNativeAdDataObjects.firstObject;
    NSString *price = [@([first eCPM]) stringValue];
    [self.bridge nativeAd:self.adapter didAdServerResponseWithExt:@{ [WindMillConstant ECPM]: price }];
    NSMutableArray *adArray = [NSMutableArray array];
    for (FLNUnifiedNativeAdDataObject *obj in unifiedNativeAdDataObjects) {
        FLNUnifiedNativeAdData *data = [[FLNUnifiedNativeAdData alloc] initWithDataObject:obj];
        FLNNativeAdViewCreator *viewCreator = [[FLNNativeAdViewCreator alloc] initWithDataObject:obj bridge:self.bridge adapter:self.adapter];
        AWMMediatedNativeAd *m = [[AWMMediatedNativeAd alloc] initWithData:data viewCreator:viewCreator originAd:obj];
        [adArray addObject:m];
    }
    self.loaded = YES;
    [self.bridge nativeAd:self.adapter didLoadWithNativeAds:adArray];
}

@end
