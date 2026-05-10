//
//  OpenCVWrapper.swift
//  Photo Stitch
//
//  Created by Azuby on 7/15/25.
//

import UIKit

class OpenCVWrapper {
    static func inpaint(image: UIImage, mask: UIImage, radius: CGFloat) -> UIImage {
        return OpenCVWrapperC.inpaint(image, mask: mask, radius: radius)
    }
}
