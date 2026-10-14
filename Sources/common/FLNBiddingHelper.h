//
//  FLNBiddingHelper.h
//  WindmillSample
//

#import <Foundation/Foundation.h>

@class AWMMediaBidResult;
@protocol FLNAdProtocol;

/// 将 ToBid 竞价结果同步给遵循 FLNAdProtocol 的广告对象（竞胜 / 竞败通知）。
/// FLNAdSDK 6.2.1.1：win → second_price / winner_adn；loss → winner_price / winner_adn / loss_reason（均为 NSString）。
void FLNApplyMediaBidResult(AWMMediaBidResult *_Nullable result, id<FLNAdProtocol> _Nullable obj);
