Pod::Spec.new do |s|
  s.name             = 'FLNTobidAdapter'
  s.version          = '1.0.4'
  s.summary          = 'ToBid custom adapter for FLNAdSDK.'
  s.description      = <<-DESC
    ToBid Custom Adapter（开屏 / 插屏 / 激励 / 原生）。
    依赖 FLNAdSDK（CocoaPods）与 ToBid-iOS-RC（WindMillSDK / WindFoundation）。
    主工程需在 Podfile 中声明 FLNAdSDK 的 git 源与版本。
    注意：勿与 MintegralAdapter / MTGSDK 同时链接（_where 符号冲突）。
  DESC
  s.homepage         = 'https://github.com/FlowXGroup/FLNTobidAdapter'
  s.license          = { :type => 'Proprietary' }
  s.author           = { 'FlowXGroup' => 'noreply@example.com' }
  s.platform         = :ios, '13.0'
  s.requires_arc     = true
  s.static_framework = true

  s.source = {
    :git => 'git@github.com:FlowXGroup/FLNTobidAdapter.git',
    :tag => s.version.to_s
  }

  s.source_files        = 'Sources/**/*.{h,m}'
  s.public_header_files = 'Sources/**/*.h'

  s.dependency 'FLNAdSDK', '6.2.1.11'
  s.dependency 'ToBid-iOS-RC/ToBidSDK', '5.10.0'

  s.frameworks = 'Foundation', 'UIKit'
  s.libraries  = 'c++', 'z', 'sqlite3', 'xml2'
  s.pod_target_xcconfig = {
    'OTHER_LDFLAGS' => '$(inherited) -ObjC',
    'CLANG_ENABLE_MODULES' => 'YES'
  }
  s.user_target_xcconfig = {
    'OTHER_LDFLAGS' => '$(inherited) -ObjC'
  }
end
