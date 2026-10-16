//
//  FLNBiddingHelper.m
//  WindmillSample
//
//  按 FLNAdSDK 6.2.1.11 FLNAdProtocol：value 一律 NSString。
//  竞胜：second_price、winner_adn；竞败：winner_price、winner_adn、loss_reason。
//  winner_adn 映射为 FLN 约定：csj/gdt/bd/ks/sigmob/mtg/inmobi/other/unknown。
//  loss_reason 仅透传 FLN 码 100/201/202/203/900；其余 ToBid reason 归为 900。
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

/// FLN loss_reason：100 / 201 / 202 / 203 / 900。无结果或无法对应时用 900。
static NSString *FLNLossReason(TBBidResultModel *bid) {
    if (!bid) {
        return @"900";
    }
    switch (bid.reason) {
        case TBReasonTimeout:
            return @"100";
        case TBReasonNoFill:
            return @"201";
        case TBReasonAboveBottomPrice:
            return @"202";
        case TBReasonBidFailed:
            return @"203";
        default:
            return @"900";
    }
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
            NSString *lossReason = FLNLossReason(bid);
            NSDictionary<NSString *, NSString *> *info = @{
                @"winner_price": FLNStringPrice(bid.winEcpm, 0),
                @"winner_adn": winnerAdn ?: @"",
                @"loss_reason": lossReason,
            };
            [obj sendLossNotificationWithInfo:info];
        }
    }
}
