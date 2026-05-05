//
//  IdiomHelpers.swift
//  PrinttoSize
//
//  Created by TapUniverse Dev9 on 3/2/25.
//

import UIKit

fileprivate let ipadPortraitSameIphone = true

var isPortrait = UIDevice.current.orientation == .portrait || UIDevice.current.orientation == .portraitUpsideDown {
    didSet {
        if oldValue != isPortrait {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NotificationCenter.default.post(name: IdiomHelpers.orientationChange, object: nil)
            }
        }
    }
}
var isIpad = UIDevice.current.userInterfaceIdiom == .pad
var isIpadFlex = UIDevice.current.userInterfaceIdiom == .pad && !(ipadPortraitSameIphone && isPortrait)
var isIphone = UIDevice.current.userInterfaceIdiom == .phone || (ipadPortraitSameIphone && UIDevice.current.userInterfaceIdiom == .pad && isPortrait)

class IdiomHelpers {
    static let shared = IdiomHelpers()
    
    static let orientationTrack = Notification.Name(UUID().uuidString)
    static let orientationChange = Notification.Name(UUID().uuidString)
    
    /**
     Use on big view of any UIViewController (usually Home) layoutsubviews
     */
    static func trackOrientation(on view: UIView) {
        isPortrait = view.bounds.width < view.bounds.height
        isIpadFlex = UIDevice.current.userInterfaceIdiom == .pad && !(ipadPortraitSameIphone && isPortrait)
        isIphone = UIDevice.current.userInterfaceIdiom == .phone || (ipadPortraitSameIphone && UIDevice.current.userInterfaceIdiom == .pad && isPortrait)
        
        NotificationCenter.default.post(name: IdiomHelpers.orientationTrack, object: nil)
    }
}

class NSLayoutConstraintIdiom: NSLayoutConstraint {
    private lazy var didLoads = [false, false, false]
    
    @IBInspectable var iphone_constant: CGFloat = -1 {
        didSet {
            didLoads[0] = true
            
            orientationChange()
            
            NotificationCenter.default.addObserver(self, selector: #selector(orientationChange), name: IdiomHelpers.orientationTrack, object: nil)
        }
    }
    
    @IBInspectable var ipadFlex_constant: CGFloat = -1 {
        didSet {
            didLoads[1] = true
            
            orientationChange()
            
            NotificationCenter.default.addObserver(self, selector: #selector(orientationChange), name: IdiomHelpers.orientationTrack, object: nil)
        }
    }
    
    @IBInspectable var ipad_constant: CGFloat = -1 {
        didSet {
            didLoads[2] = true
            
            orientationChange()
            
            NotificationCenter.default.addObserver(self, selector: #selector(orientationChange), name: IdiomHelpers.orientationTrack, object: nil)
        }
    }
    
    @objc private func orientationChange() {
        let values = [iphone_constant, ipadFlex_constant, ipad_constant]
        for (index, didLoad) in didLoads.enumerated() {
            if didLoad == false && values[index] != -1 {
                return
            }
        }
        
        if isIpad && ipad_constant != -1 {
            constant = ipad_constant
            return
        }
        
        if isIphone && iphone_constant != -1 {
            constant = iphone_constant
            return
        }
        
        if isIpadFlex && ipadFlex_constant != -1 {
            constant = ipadFlex_constant
            return
        }
    }
}

class UIViewIdiom: UIView {
    private lazy var didLoads = [false, false, false]
    
    @IBInspectable var isPointSubviews: Bool = true
    
    @IBInspectable var iphone_isShow: Int = -1 {
        didSet {
            didLoads[0] = true
            
            orientationChange()
        }
    }
    
    @IBInspectable var ipadFlex_isShow: Int = -1 {
        didSet {
            didLoads[1] = true
            
            orientationChange()
        }
    }
    
    @IBInspectable var ipad_isShow: Int = -1 {
        didSet {
            didLoads[2] = true
            
            orientationChange()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChange), name: IdiomHelpers.orientationTrack, object: nil)
    }
    
    @objc private func orientationChange() {
        let values = [iphone_isShow, ipadFlex_isShow, ipad_isShow]
        for (index, didLoad) in didLoads.enumerated() {
            if didLoad == false && values[index] != -1 {
                return
            }
        }
        
        if isIpad && ipad_isShow != -1 {
            isHidden = ipad_isShow != 1
            alpha = CGFloat(ipad_isShow)
            isUserInteractionEnabled = ipad_isShow == 1
            return
        }
        
        if isIphone && iphone_isShow != -1 {
            isHidden = iphone_isShow != 1
            alpha = CGFloat(iphone_isShow)
            isUserInteractionEnabled = iphone_isShow == 1
            return
        }
        
        if isIpadFlex && ipadFlex_isShow != -1 {
            isHidden = ipadFlex_isShow != 1
            alpha = CGFloat(ipadFlex_isShow)
            isUserInteractionEnabled = ipadFlex_isShow == 1
            return
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard isPointSubviews else {
            return super.point(inside: point, with: event)
        }
        
        var isTouch = false
        for subview in subviews {
            if subview.point(inside: convert(point, to: subview), with: event) && subview.alpha > 0.01 && subview.isUserInteractionEnabled {
                isTouch = true
                break
            }
        }
        return isTouch
    }
}

class UIStackViewIdiom: UIStackView {
    private lazy var didLoads = [false, false, false]
    
    @IBInspectable var isPointSubviews: Bool = true
    
    @IBInspectable var iphone_axis: Int = -1 {
        didSet {
            didLoads[0] = true
            
            orientationChange()
        }
    }
    
    @IBInspectable var ipadFlex_axis: Int = -1 {
        didSet {
            didLoads[1] = true
            
            orientationChange()
        }
    }
    
    @IBInspectable var ipad_axis: Int = -1 {
        didSet {
            didLoads[2] = true
            
            orientationChange()
        }
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChange), name: IdiomHelpers.orientationTrack, object: nil)
    }
    
    @objc private func orientationChange() {
        let values = [iphone_axis, ipadFlex_axis, ipad_axis]
        for (index, didLoad) in didLoads.enumerated() {
            if didLoad == false && values[index] != -1 {
                return
            }
        }
        
        if isIpad && ipad_axis != -1 {
            axis = ipad_axis == 0 ? .horizontal : .vertical
            return
        }
        
        if isIphone && iphone_axis != -1 {
            axis = iphone_axis == 0 ? .horizontal : .vertical
            return
        }
        
        if isIpadFlex && ipadFlex_axis != -1 {
            axis = ipadFlex_axis == 0 ? .horizontal : .vertical
            return
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard isPointSubviews else {
            return super.point(inside: point, with: event)
        }
        
        var isTouch = false
        for subview in subviews {
            if subview.point(inside: convert(point, to: subview), with: event) && subview.alpha > 0.01 && subview.isUserInteractionEnabled {
                isTouch = true
                break
            }
        }
        return isTouch
    }
}

extension UIView {
    func getOrientation() -> UIInterfaceOrientation? {
        guard let scene = window?.windowScene else {
            return nil
        }
        
        let orientation: UIInterfaceOrientation
        
        if #available(iOS 16.0, *) {
            orientation = scene.effectiveGeometry.interfaceOrientation
        } else {
            orientation = scene.interfaceOrientation
        }
        
        return orientation
    }
}
