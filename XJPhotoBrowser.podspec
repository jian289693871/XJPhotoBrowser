#
#  Be sure to run `pod spec lint XXDownloader.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "XJPhotoBrowser"
  s.version      = "1.1.3"
  s.summary      = "Photo Browser"
  s.homepage     = "https://github.com/jian289693871/XJPhotoBrowser"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "xj" => "289693871@qq.com" }
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/jian289693871/XJPhotoBrowser.git", :tag => "#{s.version}" }
  s.source_files  = "XJPhotoBrowser/*.{h,m}"
  s.public_header_files = 'XJPhotoBrowser/*.{h}'
  s.requires_arc = true
  s.frameworks = 'UIKit'

  s.dependency "YYWebImage", "~> 1.0.5"
end
