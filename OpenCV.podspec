Pod::Spec.new do |s|
  s.name = 'OpenCV'
  s.version = '4.12.0'
  s.summary = 'OpenCV (Computer Vision) for iOS. Prebuilt xcframework with arm64 simulator support.'
  s.homepage = 'https://opencv.org'
  s.license = { :type => 'Apache License, Version 2.0', :text => 'See https://github.com/opencv/opencv/blob/4.x/LICENSE' }
  s.authors = 'https://github.com/opencv/opencv/graphs/contributors'
  s.documentation_url = 'https://docs.opencv.org/4.x/'
  s.source = {
    :http => 'https://github.com/yeatse/opencv-spm/releases/download/4.12.0/opencv2.xcframework.zip'
  }
  s.platform = :ios, '14.0'
  s.vendored_frameworks = 'build/opencv2.xcframework'
  s.libraries = 'c++'
  s.frameworks = [
    'Accelerate',
    'AVFoundation',
    'CoreGraphics',
    'CoreImage',
    'CoreMedia',
    'CoreVideo',
    'Foundation',
    'QuartzCore',
    'UIKit'
  ]
  s.requires_arc = false
end
