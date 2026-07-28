//
//  FLNAdProtocol.h
//  FLNAdSDK
//
//  Created by fan on 2026/2/22.
//

#ifndef FLNAdProtocol_h
#define FLNAdProtocol_h

@protocol FLNAdProtocol <NSObject>

@optional
 
/**
 *  竞胜之后调用，需要在调用广告 show 之前调用。
 *
 *  @param winInfo 字典类型；各 value 请传 `NSString`。
 *  单位：分（可为小数）。
 *  - second_price（次高价，结算价）
 *  - winner_adn（竞胜平台）
 */
- (void)sendWinNotificationWithInfo:(NSDictionary<NSString *, NSString *> *)winInfo;

/**
 *  竞败之后或未参竞调用。
 *
 *  @param lossInfo 字典类型；各 value 请传 `NSString`。
 *  单位：分（可为小数）。
 *  - winner_price（竞赢方最高价）
 *  - winner_adn（竞胜平台）
 *  - loss_reason（竞败原因）
 */
- (void)sendLossNotificationWithInfo:(NSDictionary<NSString *, NSString *> *)lossInfo;

@end
#endif /* FLNAdProtocol_h */
