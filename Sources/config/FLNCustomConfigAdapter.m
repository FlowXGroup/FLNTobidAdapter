//
//  FLNCustomConfigAdapter.m
//  WindmillSample
//
//  extra 约定：appId（必填）、userId（可选）。初始化结果回主线程通知 bridge。
//

#import "FLNCustomConfigAdapter.h"
#import <FLNAdSDK/FLNAdSDKManager.h>
#import <FLNAdSDK/FLNInitConfig.h>

@interface FLNCustomConfigAdapter ()
@property (nonatomic, weak) id<AWMCustomConfigAdapterBridge> bridge;
@end

@implementation FLNCustomConfigAdapter

- (instancetype)initWithBridge:(id<AWMCustomConfigAdapterBridge>)bridge {
    self = [super init];
    if (self) {
        _bridge = bridge;
    }
    return self;
}

- (AWMCustomAdapterVersion *)basedOnCustomAdapterVersion {
    return [AWMCustomAdapterVersion V2_0];
}

- (NSString *)adapterVersion {
    return @"1.0.4";
}

- (NSString *)networkSdkVersion {
    return [FLNAdSDKManager sdkVersion];
}

- (void)initializeAdapterWithConfiguration:(AWMSdkInitConfig *)initConfig {
    // ToBid 控制台配置的媒体扩展字段进入 initConfig.extra。
    NSString *appId = [initConfig.extra objectForKey:@"appId"];
    FLNInitConfig *cfg = [[FLNInitConfig alloc] init];
    cfg.appId = appId;
    NSString *uid = [initConfig.extra objectForKey:@"userId"];
    if (uid.length) {
        cfg.userId = uid;
    }
    [[FLNAdSDKManager sharedInstance] startWithConfig:cfg completionHandler:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [self.bridge initializeAdapterSuccess:self];
            } else {
                [self.bridge initializeAdapterFailed:self error:error];
            }
        });
    }];
}

- (void)didRequestAdPrivacyConfigUpdate:(NSDictionary *)config {
    (void)config;
}

@end
