//
//  FLNUnifiedNativeAdData.m
//  WindmillSample
//
//  将 FLNUnifiedNativeAdDataObject 映射为 AWMMediatedNativeAdData（标题、图、视频模式等）。
//

#import "FLNUnifiedNativeAdData.h"
#import <FLNAdSDK/FLNUnifiedNativeAdDataObject.h>

@interface FLNUnifiedNativeAdData () {
    NSArray *_imageUrlList;
    WindMillAdn _networkId;
    AWMADImage *_videoCoverImage;
    NSString *_videoUrl;
    NSArray<AWMADImage *> *_imageModelList;
    AWMNativeAdSlotAdType _adType;
}
@property (nonatomic, strong) FLNUnifiedNativeAdDataObject *dataObject;
@end

@implementation FLNUnifiedNativeAdData

@synthesize adMode = _adMode;
@synthesize networkId = _networkId;
@synthesize videoCoverImage = _videoCoverImage;
@synthesize videoUrl = _videoUrl;
@synthesize imageModelList = _imageModelList;
@synthesize imageUrlList = _imageUrlList;
@synthesize adType = _adType;
@synthesize desc;
@synthesize callToAction;
@synthesize iconUrl;
@synthesize title;
@synthesize rating;


- (instancetype)initWithDataObject:(FLNUnifiedNativeAdDataObject *)dataObject {
    self = [super init];
    if (self) {
        _dataObject = dataObject;
        _networkId = 0;
        _adType = AWMNativeAdSlotAdTypeFeed;
    }
    return self;
}

- (NSString *)title {
    return self.dataObject.title;
}

- (NSString *)desc {
    return self.dataObject.desc;
}

- (NSString *)iconUrl {
    return self.dataObject.iconUrl;
}

- (NSString *)callToAction {
    if (self.dataObject.callToAction.length) {
        return self.dataObject.callToAction;
    }
    return self.dataObject.buttonText ?: @"查看详情";
}

- (double)rating {
    return 0;
}

- (NSArray *)imageUrlList {
    return self.dataObject.imageUrl ?: _imageUrlList;
}

- (void)setImageUrlList:(NSArray *)imageUrlList {
    _imageUrlList = imageUrlList;
}

- (NSArray<AWMADImage *> *)imageModelList {
    if (_imageModelList) {
        return _imageModelList;
    }
    NSArray *urls = self.dataObject.imageUrl;
    if (urls.count < 1) {
        return nil;
    }
    NSMutableArray<AWMADImage *> *list = [NSMutableArray arrayWithCapacity:urls.count];
    for (id item in urls) {
        if (![item isKindOfClass:[NSString class]] || [(NSString *)item length] < 1) {
            continue;
        }
        AWMADImage *image = [[AWMADImage alloc] init];
        image.imageURL = item;
        image.width = (float)self.dataObject.imageWidth;
        image.height = (float)self.dataObject.imageHeight;
        [list addObject:image];
    }
    _imageModelList = list.count > 0 ? [list copy] : nil;
    return _imageModelList;
}

- (NSString *)videoUrl {
    return self.dataObject.videoUrl;
}

- (AWMADImage *)videoCoverImage {
    if (_videoCoverImage) {
        return _videoCoverImage;
    }
    NSString *cover = self.dataObject.videoImageUrl;
    if (cover.length < 1) {
        return nil;
    }
    AWMADImage *image = [[AWMADImage alloc] init];
    image.imageURL = cover;
    image.width = (float)self.dataObject.imageWidth;
    image.height = (float)self.dataObject.imageHeight;
    _videoCoverImage = image;
    return _videoCoverImage;
}

- (AWMMediatedNativeAdMode)adMode {
    if (_adMode > 0) {
        return _adMode;
    }
    if (self.dataObject.videoUrl.length > 0) {
        _adMode = AWMMediatedNativeAdModeVideo;
    } else if (self.dataObject.imageUrl.count >= 3) {
        _adMode = AWMMediatedNativeAdModeGroupImage;
    } else if (self.dataObject.imageHeight > self.dataObject.imageWidth * 1.2 && self.dataObject.imageWidth > 0) {
        _adMode = AWMMediatedNativeAdModePortraitImage;
    } else {
        _adMode = AWMMediatedNativeAdModeLargeImage;
    }
    return _adMode;
}

- (AWMNativeAdSlotAdType)adType {
    return _adType;
}

- (void)setAdType:(AWMNativeAdSlotAdType)adType {
    _adType = adType;
}

- (AWMNativeAdInteractionType)interactionType {
    return self.dataObject.isAppAd ? AWMNativeAdInteractionTypeDownload : AWMNativeAdInteractionTypePage;
}



@synthesize interactionType;

@end
