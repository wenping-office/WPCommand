#
#  Be sure to run `pod spec lint IFMMenu.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  s.name             = 'WPCommand'
  s.version          = '0.1.0'
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
