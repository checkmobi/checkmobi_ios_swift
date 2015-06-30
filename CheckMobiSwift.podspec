#
# Be sure to run `pod lib lint CheckMobiSwift.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "CheckMobiSwift"
  s.version          = "0.1.0"
  s.summary          = "CheckMobi SDK for swift."
  s.description      = <<-DESC
                       An optional longer description of CheckMobiSwift

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/checkmobi/checkmobi_ios_swift"
  s.author           = { "CheckMobi" => "support@checkmobi.com" }
  s.source           = { :git => "https://github.com/checkmobi/checkmobi_ios_swift.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/checkmobi'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'CheckMobiSwift' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
