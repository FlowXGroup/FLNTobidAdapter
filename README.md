# FLNTobidAdapter

ToBid 自定义 Adapter，已内含 `FLNAdSDK.xcframework`。

## 要求

- iOS 13.0+
- 内含 `FLNAdSDK` 6.2.0.17
- `ToBid-iOS-RC` 5.7.4（或兼容的 ToBid / WindMillSDK）
- **不要**同时集成 `MintegralAdapter` / MTGSDK（与 FLNAdSDK 存在 `_where` 符号冲突）

## 接入

```ruby
platform :ios, '13.0'
use_frameworks!

pod 'FLNTobidAdapter',
  :git => 'git@github.com:FlowXGroup/FLNTobidAdapter.git',
  :tag => '1.0.1'

pod 'ToBid-iOS-RC', '5.7.4', :subspecs => [
  # ... 按需选择；不要 MintegralAdapter
]
```

```bash
pod install
```

主工程无需再单独拖入 / pod `FLNAdSDK`。

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
