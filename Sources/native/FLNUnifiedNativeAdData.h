//
//  FLNNativeAdData.h
//  WindmillSample
//

#import <Foundation/Foundation.h>
#import <WindMillSDK/WindMillSDK.h>

@class FLNUnifiedNativeAdDataObject;

@interface FLNUnifiedNativeAdData : NSObject <AWMMediatedNativeAdData>

- (instancetype)initWithDataObject:(FLNUnifiedNativeAdDataObject *)dataObject;

@end
