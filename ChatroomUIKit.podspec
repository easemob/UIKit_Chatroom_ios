#
# Be sure to run `pod lib lint ChatroomUIKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'ChatroomUIKit'
  s.version          = '1.1.0'
  s.summary          = 'ChatroomUIKit.'


  s.description      = <<-DESC
This product is mainly designed to solve most user needs for chat rooms in pan-entertainment business scenarios. It mainly solves the problem for users that directly integrating the SDK is cumbersome and complex, and some APIs have poor experience (from the perspective of user-side developers) )And other issues. We are committed to creating chat room UIKit products with simple integration, high degree of freedom, simple process, and sufficiently detailed documentation.
                       DESC

  s.homepage         = 'https://github.com/easemob/UIKit_Chatroom_ios'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zjc19891106' => '984065974@qq.com' }
  s.source           = { :git => 'https://github.com/easemob/UIKit_Chatroom_ios.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://github.com/zjc19891106'

  s.ios.deployment_target = '13.0'
  s.xcconfig = {'ENABLE_BITCODE' => 'NO'}
  

  s.source_files = ['Sources/ChatroomUIKit/Classes/**/*.swift']
  s.resources = ['Sources/ChatroomUIKit/**/*.bundle']
  s.dependency 'HyphenateChat'
  
  s.static_framework = true
  
  s.swift_version = '5.0'


#  s.source_files = 'Sources/ChatroomUIKit/Classes/**/*'

  # s.public_header_files = 'Pod/Classes/**/*.h'
   s.frameworks = 'UIKit', 'Foundation','Combine'
end

