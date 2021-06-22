Pod::Spec.new do |s|
  s.name = 'ApplozicSwift'
  s.version = '6.1.1'
  s.license = { :type => "BSD 3-Clause", :file => "LICENSE" }
  s.summary = 'Applozic Swift Kit'
  s.homepage = 'https://github.com/AppLozic/ApplozicSwift'
  s.social_media_url = 'http://twitter.com/AppLozic'
  s.authors = { 'Applozic Inc.' => 'support@applozic.com' }

  s.source = { :git => 'https://github.com/AppLozic/ApplozicSwift.git', :tag => s.version }

  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'

  s.default_subspec = 'Complete'

  s.subspec 'RichMessageKit' do |richMessage|
    richMessage.source_files = 'RichMessageKit/**/*.swift'
    richMessage.resources = 'RichMessageKit/**/*{xcassets}'
  end

  s.subspec 'Complete' do |complete|
    complete.source_files = 'Sources/**/*.swift'
    complete.resources = 'Sources/**/*{lproj,storyboard,xib,xcassets,json}'
    complete.dependency 'Kingfisher', '~> 6.3.0'
    complete.dependency 'SwipeCellKit', '~> 2.7.1'
    complete.dependency 'ApplozicCore', '~> 8.1.0'
    complete.dependency 'ApplozicSwift/RichMessageKit'
  end
end
