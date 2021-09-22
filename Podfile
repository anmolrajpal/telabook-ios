# Uncomment the next line to define a global platform for your project

platform :ios, '13.0'
source 'https://github.com/CocoaPods/Specs.git'
source "https://gitlab.linphone.org/BC/public/podspec.git"

target 'Telabook' do
	use_frameworks!
	pod 'Firebase'
	pod 'Firebase/Core'
	pod 'Firebase/Database'
  pod 'Firebase/Storage'
	pod 'Firebase/Auth'
  pod 'Firebase/Messaging'
	pod 'ReachabilitySwift'
  pod 'MessageKit'
  pod 'PINRemoteImage'
  pod 'GooglePlaces'
  pod 'linphone-sdk' , '4.4.7'
end


post_install do |installer|
  installer.pods_project.targets.each do |t|
    t.build_configurations.each do |bc|
      if bc.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] == '8.0'
        bc.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
      end
      # bc.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
      bc.build_settings["ONLY_ACTIVE_ARCH"] = "YES"
    end
  end
end
