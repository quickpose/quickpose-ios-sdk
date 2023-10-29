Pod::Spec.new do |s|
s.name             = 'QuickPoseCamera'
s.version = '1.2.5'
s.summary          = 'QuickPoseCamera'
s.homepage         = 'https://quickpose.ai'
s.authors          = 'QuickPose.ai'
s.license = { :type => "QuickPose", :file => "LICENSE" }

s.source           = {
:git => 'https://github.com/quickpose/quickpose-ios-sdk.git',
:tag => 'v' + s.version.to_s
}
s.platform = :ios
s.module_name   = 'QuickPoseCamera'

s.ios.deployment_target = '14.0'
s.cocoapods_version = '>= 1.4.0'

s.swift_version = '5.3'

s.default_subspecs = 'Camera'

s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }


s.subspec 'Camera' do |ss|
	ss.dependency 'QuickPoseCore'
	ss.platform = :ios
	ss.ios.deployment_target = '14.0'
	ss.source_files = 'Sources/QuickPoseCamera/*.swift'
end


end
