# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'PhotoStitch2.0' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for PhotoStitch2.0

  pod 'OpenCV'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
    end
  end
end
