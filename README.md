# FLNTobidAdapter

ToBid 自定义 Adapter，依赖 `FLNAdSDK`（CocoaPods）与 `ToBid-iOS-RC`。

## 要求

- iOS 13.0+
- `FLNAdSDK` 6.2.2.1（Podfile 需声明 git 源）
- `ToBid-iOS-RC` 5.10.2（或兼容的 ToBid / WindMillSDK）
- **不要**同时集成 `MintegralAdapter` / MTGSDK（与 FLNAdSDK 存在 `_where` 符号冲突）

## 接入

```ruby
platform :ios, '13.0'
use_frameworks!

pod 'FLNAdSDK',
  :git => 'https://github.com/FlowXGroup/FLNAdSDK-iOS.git',
  :tag => '6.2.2.1'

pod 'FLNTobidAdapter',
  :git => 'git@github.com:FlowXGroup/FLNTobidAdapter.git',
  :tag => '1.0.4'
# 本地调试可用：:path => '../FLNTobidAdapter'

pod 'ToBid-iOS-RC', '5.10.2', :subspecs => [
  # ... 按需选择；不要 MintegralAdapter
]
```

```bash
pod install
```

主工程不要再拖入 `FLNAdSDK.xcframework`，也不要再编译一份 Adapter 源码。

## ToBid 控制台类名

| 用途 | 类名 |
|------|------|
| 初始化 | `FLNCustomConfigAdapter` |
| 开屏 | `FLNCustomSplashAdapter` |
| 激励视频 | `FLNCustomRewardedVideoAdapter` |
| 插屏 | `FLNCustomInterstitialAdapter` |
| 原生 | `FLNCustomNativeAdapter` |

### 媒体扩展字段（初始化）

| Key | 必填 | 说明 |
|-----|------|------|
| `appId` | 是 | FLN 媒体 AppId |
| `userId` | 否 | 用户标识 |

### 原生

| Key | 值 | 行为 |
|-----|----|------|
| `templateType` | `1` | 自渲染 |
| 其他 / 缺省 | — | 模板渲染 |

广告位 `placementId` 对应 FLN `posId`。
