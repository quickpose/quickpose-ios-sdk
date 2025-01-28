Pod::Spec.new do |s|
s.name             = 'QuickPoseSwiftUI'
s.version = '1.2.10'
s.summary          = 'QuickPoseSwiftUI'
s.homepage         = 'https://quickpose.ai'
s.authors          = 'QuickPose.ai'
s.license = { :type => "QuickPose", :file => "LICENSE" }

s.source           = {
:git => 'https://github.com/quickpose/quickpose-ios-sdk.git',
:tag => 'v' + s.version.to_s
}
s.platform = :ios
s.module_name   = 'QuickPoseSwiftUI'

s.ios.deployment_target = '14.0'
s.cocoapods_version = '>= 1.4.0'

s.swift_version = '5.3'

s.default_subspecs = 'SwiftUI'


s.subspec 'SwiftUI' do |ss|
	ss.platform = :ios
	ss.ios.deployment_target = '14.0'
	ss.dependency 'QuickPoseCamera'
	ss.source_files = 'Sources/QuickPoseSwiftUI/*.swift'
end


end
