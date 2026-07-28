//
//  FLNCustomAdProtocol.h
//  WindmillSample
//
//  自定义适配器内部能力抽象（与 FLN SDK 的 FLNAdProtocol 区分命名）。
//

@class AWMParameter;
@class AWMMediaBidResult;
@class UIViewController;
@protocol AWMCustomAdapter;
@protocol AWMCustomAdapterBridge;

@protocol FLNCustomAdProtocol <NSObject>
@optional
- (instancetype)initWithBridge:(id<AWMCustomAdapterBridge>)bridge
                       adapter:(id<AWMCustomAdapter>)adapter;

- (void)loadAdWithPlacementId:(NSString *)placementId
                    parameter:(AWMParameter *)parameter;

- (void)loadAdWithPlacementId:(NSString *)placementId
                       adSize:(CGSize)size
                    parameter:(AWMParameter *)parameter;

- (BOOL)mediatedAdStatus;

- (void)showAdFromRootViewController:(UIViewController *)viewController parameter:(AWMParameter *)parameter;

- (void)didReceiveBidResult:(AWMMediaBidResult *)result;

@end
