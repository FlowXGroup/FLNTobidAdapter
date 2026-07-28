//
//  FLNNativeAdViewCreator.h
//  WindmillSample
//

#import <Foundation/Foundation.h>
#import <WindMillSDK/WindMillSDK.h>

@class FLNUnifiedNativeAdDataObject;
@class FLNNativeExpressAdView;

@interface FLNNativeAdViewCreator : NSObject <AWMMediatedNativeAdViewCreator>

- (instancetype)initWithDataObject:(FLNUnifiedNativeAdDataObject *)dataObject
                            bridge:(id<AWMCustomNativeAdapterBridge>)bridge
                           adapter:(id<AWMCustomNativeAdapter>)adapter;

- (instancetype)initWithExpressAdView:(FLNNativeExpressAdView *)adView
                                 bridge:(id<AWMCustomNativeAdapterBridge>)bridge
                                adapter:(id<AWMCustomNativeAdapter>)adapter;

@end
