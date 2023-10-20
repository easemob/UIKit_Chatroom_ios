#
# Be sure to run `pod lib lint ChatroomUIKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ChatroomUIKit'
  s.version          = '0.1.0'
  s.summary          = 'A short description of ChatroomUIKit.'


  s.description      = <<-DESC
A chat room UIKit that is easy to use, efficient, innovative and rich in custom themes, easy to create a better chat room experience.
                       DESC

  s.homepage         = 'https://github.com/zjc19891106/ChatroomUIKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zjc19891106' => '984065974@qq.com' }
  s.source           = { :git => 'https://github.com/zjc19891106/ChatroomUIKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://github.com/zjc19891106'

  s.ios.deployment_target = '13.0'
  s.xcconfig = {'ENABLE_BITCODE' => 'NO'}
  
  s.subspec 'Service' do |ss|
      ss.source_files = [
        'Sources/ChatroomUIKit/Classes/Service/**/*'
      ]
      ss.dependency 'HyphenateChat'
      ss.dependency 'KakaJSON'
  end

  s.subspec 'UI' do |ss|
    ss.source_files = [
      'Sources/ChatroomUIKit/Classes/UI/**/*.swift'
    ]
    ss.resources = ['Sources/ChatroomUIKit/**/*.bundle']

  end
  
  s.static_framework = true
  
  s.swift_version = '5.0'
  

  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }


#  s.source_files = 'Sources/ChatroomUIKit/Classes/**/*'

  # s.public_header_files = 'Pod/Classes/**/*.h'
   s.frameworks = 'UIKit', 'Foundation','Combine'
end
