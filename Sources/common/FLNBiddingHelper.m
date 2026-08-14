//
//  FLNBiddingHelper.m
//  WindmillSample
//
//  按 FLNAdSDK 6.2.0.17 FLNAdProtocol：value 一律 NSString。
//  竞胜：second_price、winner_adn；竞败：winner_price、winner_adn、loss_reason。
//  winner_adn 映射为 FLN 约定：csj/gdt/bd/ks/sigmob/mtg/inmobi/other/unknown。
//

#import "FLNBiddingHelper.h"
#import <FLNAdSDK/FLNAdProtocol.h>
#import <WindMillSDK/WindMillSDK.h>

static NSString *FLNStringPrice(NSString *price, int64_t fallback) {
    if (price.length > 0) {
        return price;
    }
    return [NSString stringWithFormat:@"%lld", (long long)fallback];
}

static NSString *FLNWinnerAdnName(TBBidResultModel *bid) {
    if (!bid) {
        return @"unknown";
    }
    switch (bid.adn) {
        case WindMillAdnCSJ:
        case WindMillAdnPangle:
            return @"csj";
        case WindMillAdnGDT:
            return @"gdt";
        case WindMillAdnBaidu:
            return @"bd";
        case WindMillAdnKs:
            return @"ks";
        case WindMillAdnSigmob:
            return @"sigmob";
        case WindMillAdnMTG:
            return @"mtg";
        case WindMillAdnInMobi:
            return @"inmobi";
        case WindMillAdnNone:
            return @"unknown";
        default:
            return @"other";
    }
}

void FLNApplyMediaBidResult(AWMMediaBidResult *result, id<FLNAdProtocol> obj) {
    if (!obj || !result) {
        return;
    }
    TBBidResultModel *bid = result.bidResult;
    NSString *winnerAdn = FLNWinnerAdnName(bid);

    if (result.win) {
        if ([obj respondsToSelector:@selector(sendWinNotificationWithInfo:)]) {
            // second_price：次高价/结算价（对应 ToBid lossEcpm）；无则回退 winnerPrice
            NSDictionary<NSString *, NSString *> *info = @{
                @"second_price": FLNStringPrice(bid.lossEcpm, result.winnerPrice),
                @"winner_adn": winnerAdn ?: @"",
            };
            [obj sendWinNotificationWithInfo:info];
        }
    } else {
        if ([obj respondsToSelector:@selector(sendLossNotificationWithInfo:)]) {
            NSString *lossReason = bid ? [NSString stringWithFormat:@"%ld", (long)bid.reason] : @"102";
            NSDictionary<NSString *, NSString *> *info = @{
                @"winner_price": FLNStringPrice(bid.winEcpm, 0),
                @"winner_adn": winnerAdn ?: @"",
                @"loss_reason": lossReason,
            };
            [obj sendLossNotificationWithInfo:info];
        }
    }
}
