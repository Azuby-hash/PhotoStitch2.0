//
//  UIViewLoadNib.swift
//  AIVideoGenerator
//
//  Created by TapUniverse Dev9 on 11/04/2024.
//

import UIKit

extension UIView {
    func loadNib() {
        let nib = UINib(nibName: String(NSStringFromClass(type(of: self)).split(separator: ".").last ?? ""), bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = false
        addSubview(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
