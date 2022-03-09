Pod::Spec.new do |s|
  s.name = 'KommunicateChatUI-iOS-SDK'
  s.version = '0.2.0'
  s.license = { :type => "BSD 3-Clause", :file => "LICENSE" }
  s.summary = 'KommunicateChatUI-iOS-SDK Kit'
  s.homepage = 'https://github.com/Kommunicate-io/KommunicateChatUI-iOS-SDK'
  s.author = { 'Mukesh Thawani' => 'mukesh@applozic.com' }

  s.source = { :git => 'https://github.com/Kommunicate-io/KommunicateChatUI-iOS-SDK.git', :tag => s.version }

  s.ios.deployment_target = '12.0'
  s.swift_version = '5.0'

  s.default_subspec = 'Complete'

  s.subspec 'RichMessageKit' do |richMessage|
    richMessage.source_files = 'RichMessageKit/**/*.swift'
    richMessage.resources = 'RichMessageKit/**/*{xcassets}'
  end

  s.subspec 'Complete' do |complete|
    complete.source_files = 'Sources/**/*.swift'
    complete.resources = 'Sources/**/*{lproj,storyboard,xib,xcassets,json}'
    complete.dependency 'Kingfisher', '~> 7.0.0'
    complete.dependency 'SwipeCellKit', '~> 2.7.1'
    complete.dependency 'KommunicateCore-iOS-SDK', '~> 1.0.0'
    complete.dependency 'KommunicateChatUI-iOS-SDK/RichMessageKit'
  end
end
