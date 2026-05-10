//
//  OpenCVWrapper.m
//  ModuleTest
//
//  Created by TapUniverse Dev9 on 25/10/2023.
//

#import <iostream>
#import "OpenCVWrapper.h"
#import "UIKit/UIKit.h"
#import <opencv2/photo.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/imgproc.hpp>
#import <opencv2/calib3d.hpp>
#import <opencv2/features2d.hpp>

using namespace std;
using namespace cv;

@implementation OpenCVWrapperC
+(UIImage*)inpaint:(UIImage*) image mask:(UIImage*) mask radius:(CGFloat) radius {
    Mat _image;
    Mat _mask;
    Mat _output;
    
    // Convert UIImage to cv::Mat
    UIImageToMat(image, _image);
    UIImageToMat(mask, _mask);
    
    // Ensure input image is 3-channel RGB
    if (_image.channels() == 4) {
        cvtColor(_image, _image, COLOR_RGBA2RGB);
    } else if (_image.channels() == 1) {
        cvtColor(_image, _image, COLOR_GRAY2RGB);
    }
    
    // Ensure mask is 1-channel binary
    if (_mask.channels() > 1) {
        cvtColor(_mask, _mask, COLOR_BGR2GRAY);
    }
    threshold(_mask, _mask, 127, 255, THRESH_BINARY);
    
    // Inpaint
    inpaint(_image, _mask, _output, radius, INPAINT_TELEA);
    
    // Convert back to UIImage
    return MatToUIImage(_output);
}
@end
