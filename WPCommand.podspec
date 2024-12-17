#
# Be sure to run `pod lib lint WPCommand.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WPCommand'
  s.version          = '0.6.1'
  # 介绍
  s.summary          = '队列Alert、日历视图、支持嵌套TableView的PagingView、轻量级面包屑视图、自适应LatticeView、富文本语法糖、View属性语法糖、各类常用Extension等基础类库'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC
  # 项目主页
  s.homepage         = 'https://github.com/wenping-office/WPCommand'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '文平' => 'wenping.office@foxmail.com' }
  s.source           = { :git => 'https://github.com/wenping-office/WPCommand.git', :tag => s.version.to_s }
  s.swift_version='5.0'
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  # 最低支持的系统版本
  s.ios.deployment_target = '12.0'
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
   s.frameworks = 'UIKit',
 'Photos',
 'AssetsLibrary',
 'MediaPlayer',
 'CoreTelephony',
 'AVFoundation'

  
    # 第三方依赖库
     s.dependency 'SnapKit'
     #RxSwift系列
     s.dependency 'RxSwift'
     s.dependency 'RxCocoa'


     s.prefix_header_contents = '#import "Bridge.h"'
     s.prefix_header_contents = '#import "WPDateView.h"'
     
end
