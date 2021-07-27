#
# Be sure to run `pod lib lint WPCommand.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WPCommand'
  s.version          = '0.1.1'
  s.summary          = 'A short description of WPCommand.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/MyNameWp/WPCommand'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '文平' => '850500722@qq.com' }
  s.source           = { :git => 'https://github.com/MyNameWp/WPCommand.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'WPCommand/Classes/**/*'
  
  # s.resource_bundles = {
  #   'WPCommand' => ['WPCommand/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  
   s.frameworks = 'UIKit', 'MapKit', 'Photos', 'AssetsLibrary', 'MediaPlayer', 'CoreTelephony', 'CoreLocation', 'AVFoundation'
  # s.dependency 'AFNetworking', '~> 2.3'
  
  #   import Photos
#   import AssetsLibrary
#   import MediaPlayer
#   import CoreTelephony
#   import CoreLocation
#   import AVFoundation

     s.dependency 'SnapKit'
     s.dependency 'Kingfisher'
     #RxSwift系列
     s.dependency 'RxSwift'
     s.dependency 'RxCocoa'
end
