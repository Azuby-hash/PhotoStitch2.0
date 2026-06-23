//
//  UIButtonPro.swift
//  PushUpCounter
//
//  Created by TapUniverse Dev9 on 6/11/25.
//

import UIKit

class UIButtonPro: UIButton {
    @IBInspectable var inset: CGPoint = .zero

    private var titleContainer = AttributeContainer()
    private var subtitleContainer = AttributeContainer()
    private var backgroundColorConfig: UIColor = {
        if #available(iOS 26, *) {
            return UIColor.clear
        } else {
            return UIColor.systemBackground
        }
    } ()
    
    private var didLoad = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        let configuration = configuration
        self.configuration = configuration ?? .filled()
        
        updateUI()
        
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self], target: self, action: #selector(traitCollectionDidChange))
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let configuration = configuration
        self.configuration = configuration ?? .filled()
        
        updateUI()
        
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self], target: self, action: #selector(traitCollectionDidChange))
        }
    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        
        let configuration = configuration
        self.configuration = configuration ?? .filled()
        
        updateUI()
        
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self], target: self, action: #selector(traitCollectionDidChange))
        }
    }

    @objc override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let configuration = configuration
        self.configuration = configuration ?? .filled()

        // Check if the user interface style has changed
        updateUI()
    }
    
    private func updateUI() {
        var configuration = configuration
        
        configuration?.titleTextAttributesTransformer = .init({ [self] container in
            if !didLoad {
                self.titleContainer = container
            }
            
            return container
        })
        
        configuration?.subtitleTextAttributesTransformer = .init({ [self] container in
            if !didLoad {
                self.subtitleContainer = container
            }
            
            return container
        })
        
        if !didLoad,
           let backgroundColor = configuration?.baseBackgroundColor {
            self.backgroundColorConfig = backgroundColor
        }

        self.configuration = configuration
        
        didLoad = true
        
        configurationUpdateHandler = { [self] button in
            var updatedConfig: UIButton.Configuration
            
            if #available(iOS 26, *) {
                updatedConfig = UIButton.Configuration.prominentGlass()
            } else {
                updatedConfig = button.configuration ?? .filled()
            }
            
            updatedConfig.title = button.configuration?.title
            updatedConfig.subtitle = button.configuration?.subtitle
            updatedConfig.image = button.configuration?.image
            updatedConfig.imagePlacement = button.configuration?.imagePlacement ?? updatedConfig.imagePlacement
            updatedConfig.imagePadding = button.configuration?.imagePadding ?? updatedConfig.imagePadding
            updatedConfig.baseForegroundColor = button.configuration?.baseForegroundColor
            updatedConfig.contentInsets = button.configuration?.contentInsets ?? updatedConfig.contentInsets
            updatedConfig.cornerStyle = button.configuration?.cornerStyle ?? updatedConfig.cornerStyle
            updatedConfig.titleLineBreakMode = .byTruncatingTail
            updatedConfig.background = button.configuration?.background ?? updatedConfig.background
            
            if #available(iOS 26, *) {
                updatedConfig.background.backgroundColor = .clear
                updatedConfig.baseBackgroundColor = backgroundColorConfig
            } else {
                updatedConfig.background.backgroundColor = backgroundColorConfig
                updatedConfig.baseBackgroundColor = backgroundColorConfig
            }
            
            updatedConfig.titlePadding = button.configuration?.titlePadding ?? updatedConfig.titlePadding
            updatedConfig.titleAlignment = button.configuration?.titleAlignment ?? updatedConfig.titleAlignment
            
            if let title = button.configuration?.title {
                if let foregroundColor = button.configuration?.baseForegroundColor {
                    titleContainer.merge(.init([
                        .foregroundColor: foregroundColor
                    ]))
                }
                
                updatedConfig.attributedTitle = AttributedString(title, attributes: titleContainer)
            }
            
            if let subtitle = button.configuration?.subtitle {
                if let foregroundColor = button.configuration?.baseForegroundColor {
                    subtitleContainer.merge(.init([
                        .foregroundColor: foregroundColor
                    ]))
                }
                
                updatedConfig.attributedSubtitle = AttributedString(subtitle, attributes: subtitleContainer)
            }
            
            self.configuration = updatedConfig
        }
        
        tintAdjustmentMode = .normal
    }
    
    @discardableResult
    func setContentColor(_ color: UIColor) -> UIButtonPro {
        configuration?.baseForegroundColor = color
        
        updateUI()
        
        return self
    }
    
    @discardableResult
    func setBackgroundColor(_ color: UIColor) -> UIButtonPro {
        backgroundColorConfig = color
        
        if configuration?.baseBackgroundColor != .clear {
            configuration?.baseBackgroundColor = color
        }
        
        updateUI()
        
        return self
    }
    
    @discardableResult
    func einset(_ inset: CGPoint) -> UIButtonPro {
        self.inset = inset
        
        return self
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let rect = self.bounds.insetBy(dx: inset.x, dy: inset.y)
        var isTouch = false
        for subview in subviews {
            if subview.point(inside: convert(point, to: subview), with: event) {
                isTouch = true
                break
            }
        }
        
        return rect.contains(point) || isTouch
    }
}
