#
# Be sure to run `pod lib lint YFCodeScan.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YFCodeScan'
  s.version          = '0.2.1'
  s.summary          = 'A lightweight, easy-to-use code scanning library'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A lightweight, easy-to-use code scanning library.This library is built on top of Apple's excellent AVFoundation framework.
                       DESC

  s.homepage         = 'https://github.com/bluesky0109/YFCodeScan'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'bluesky0109' => 'huifeng0109@gmail.com' }
  s.source           = { :git => 'https://github.com/bluesky0109/YFCodeScan.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'YFCodeScan/Classes/**/*'
  
  s.resource_bundles = {
    'YFCodeScan' => ['YFCodeScan/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
