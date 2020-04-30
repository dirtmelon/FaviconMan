#
# Be sure to run `pod lib lint FaviconMan.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FaviconMan'
  s.version          = '0.1.0'
  s.summary          = 'A man help you to fetch favicon.'
  s.homepage         = 'https://github.com/dirtmelon/FaviconMan'
  s.license          = { type: 'MIT', file: 'LICENSE' }
  s.author           = { 'dirtmelon' => '0xffdirtmelon@gmail.com' }
  s.source           = { git: 'https://github.com/dirtmelon/FaviconMan.git', tag: s.version.to_s }
  s.social_media_url = 'https://twitter.com/Dirt_melon'
  s.ios.deployment_target = '11.0'
  s.osx.deployment_target = '10.12'
  s.tvos.deployment_target = '10.0'
  s.swift_versions = ['5.1', '5.2']
  s.source_files = ['FaviconMan/*.swift', 'FaviconMan/*.h']
  s.xcconfig = {
    'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2',
    'OTHER_LDFLAGS' => '-lxml2'
  }
end
