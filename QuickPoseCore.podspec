Pod::Spec.new do |s|
s.name             = 'QuickPoseCore'
s.version = '1.1.1'
s.summary          = 'QuickPoseCore'
s.homepage         = 'https://quickpose.ai'
s.authors          = 'QuickPose.ai'
s.license = { :type => "QuickPose", :file => "LICENSE" }

s.source           = {
:git => 'https://github.com/quickpose/quickpose-ios-sdk.git',
:tag => 'v' + s.version = '1.1.1'
}
s.platform = :ios
s.module_name   = 'QuickPoseCore'

s.ios.deployment_target = '14.0'
s.cocoapods_version = '>= 1.4.0'

s.swift_version = '5.3'

s.default_subspecs = 'Core'

s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

s.subspec 'Core' do |ss|
	ss.platform = :ios
	ss.ios.deployment_target = '14.0'

	ss.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
	ss.pod_target_xcconfig = { 'VALID_ARCHS' => 'arm64 armv7' }

	ss.ios.vendored_frameworks = 'QuickPoseCore.xcframework','QuickPoseMP.xcframework'

end


end
