#
# Be sure to run `pod lib lint WPCommand.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WPCommand'
  s.version          = '0.2.0'
  # 介绍
  s.summary          = '基础库工具类、队列Alert,TextView、TextField、等'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC
  # 项目主页
  s.homepage         = 'https://github.com/MyNameWp/WPCommand'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '文平' => '850500722@qq.com' }
  s.source           = { :git => 'https://github.com/MyNameWp/WPCommand.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  # 最低支持的系统版本
  s.ios.deployment_target = '10.0'
  # 源文件地址
  #  s.source_files = 'WPCommand/Classes/**/*'
  s.source_files = 'WPCommand/Classes/Public/**/*'
    
  # 是否支持arc
  s.requires_arc = true
  # 资源文件
  # s.resource_bundles = {
  #   'WPCommand' => ['WPCommand/Assets/*.png']
  # }
  
  # 公开头文件
  #   s.public_header_files = 'WPCommand/Classes/**/*.h'

  # 依赖系统库
   s.frameworks = 'UIKit', 'Photos', 'AssetsLibrary', 'MediaPlayer', 'CoreTelephony', 'CoreLocation', 'AVFoundation'

  
    # 第三方依赖库
     s.dependency 'SnapKit'
     #RxSwift系列
     s.dependency 'RxSwift'
     s.dependency 'RxCocoa'
#     # 第三方依赖库
#      s.dependency 'SnapKit','5.0.1'
#      s.dependency 'Kingfisher','6.3.0'
#      #RxSwift系列
#      s.dependency 'RxSwift','6.2.0'
#      s.dependency 'RxCocoa','6.2.0'

s.prefix_header_contents = '#import "Bridge.h"'
     
end
