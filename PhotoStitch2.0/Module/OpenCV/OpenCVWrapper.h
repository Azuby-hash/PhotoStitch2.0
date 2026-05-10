//
//  OpenCVWrapper.h
//  ModuleTest
//
//  Created by TapUniverse Dev9 on 25/10/2023.
//

#import "UIKit/UIKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapperC : NSObject
+(UIImage*)inpaint:(UIImage*) image mask:(UIImage*) mask radius:(CGFloat) radius;
@end

NS_ASSUME_NONNULL_END
