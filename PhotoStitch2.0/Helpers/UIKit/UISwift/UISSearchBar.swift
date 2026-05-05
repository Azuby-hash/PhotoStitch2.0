//
//  UISSearchBar.swift
//  StitchPhotos2.0
//
//  Created by TapUniverse Dev9 on 12/3/26.
//

import UIKit

extension UISearchBar {
    
    @discardableResult
    func ebarStyle(_ barStyle: UIBarStyle) -> Self {
        self.barStyle = barStyle
        return self
    }
    
    @discardableResult
    func edelegate(_ delegate: (any UISearchBarDelegate)?) -> Self {
        self.delegate = delegate
        return self
    }
    
    @discardableResult
    func etext(_ text: String?) -> Self {
        self.text = text
        return self
    }
    
    @discardableResult
    func eprompt(_ prompt: String?) -> Self {
        self.prompt = prompt
        return self
    }
    
    @discardableResult
    func eplaceholder(_ placeholder: String?) -> Self {
        self.placeholder = placeholder
        return self
    }
    
    @discardableResult
    func eshowsBookmarkButton(_ showsBookmarkButton: Bool) -> Self {
        self.showsBookmarkButton = showsBookmarkButton
        return self
    }
    
    @discardableResult
    func eshowsCancelButton(_ showsCancelButton: Bool) -> Self {
        self.showsCancelButton = showsCancelButton
        return self
    }
    
    @discardableResult
    func eshowsSearchResultsButton(_ showsSearchResultsButton: Bool) -> Self {
        self.showsSearchResultsButton = showsSearchResultsButton
        return self
    }
    
    @discardableResult
    func eisSearchResultsButtonSelected(_ isSearchResultsButtonSelected: Bool) -> Self {
        self.isSearchResultsButtonSelected = isSearchResultsButtonSelected
        return self
    }
    
    @discardableResult
    func ebarTintColor(_ barTintColor: UIColor?) -> Self {
        self.barTintColor = barTintColor
        return self
    }
    
    @discardableResult
    func esearchBarStyle(_ searchBarStyle: UISearchBar.Style) -> Self {
        self.searchBarStyle = searchBarStyle
        return self
    }
    
    @discardableResult
    func eisTranslucent(_ isTranslucent: Bool) -> Self {
        self.isTranslucent = isTranslucent
        return self
    }
    
    @discardableResult
    func escopeButtonTitles(_ scopeButtonTitles: [String]?) -> Self {
        self.scopeButtonTitles = scopeButtonTitles
        return self
    }
    
    @discardableResult
    func eselectedScopeButtonIndex(_ selectedScopeButtonIndex: Int) -> Self {
        self.selectedScopeButtonIndex = selectedScopeButtonIndex
        return self
    }
    
    @discardableResult
    func eshowsScopeBar(_ showsScopeBar: Bool) -> Self {
        self.showsScopeBar = showsScopeBar
        return self
    }
    
    @discardableResult
    func einputAccessoryView(_ inputAccessoryView: UIView?) -> Self {
        self.inputAccessoryView = inputAccessoryView
        return self
    }
    @available(iOS 16.4, *)
    
    @discardableResult
    func eisEnabled(_ isEnabled: Bool) -> Self {
        self.isEnabled = isEnabled
        return self
    }
    
    @discardableResult
    func ebackgroundImage(_ backgroundImage: UIImage?) -> Self {
        self.backgroundImage = backgroundImage
        return self
    }
    
    @discardableResult
    func escopeBarBackgroundImage(_ scopeBarBackgroundImage: UIImage?) -> Self {
        self.scopeBarBackgroundImage = scopeBarBackgroundImage
        return self
    }
    
    @discardableResult
    func esearchFieldBackgroundPositionAdjustment(_ searchFieldBackgroundPositionAdjustment: UIOffset) -> Self {
        self.searchFieldBackgroundPositionAdjustment = searchFieldBackgroundPositionAdjustment
        return self
    }
    
    @discardableResult
    func esearchTextPositionAdjustment(_ searchTextPositionAdjustment: UIOffset) -> Self {
        self.searchTextPositionAdjustment = searchTextPositionAdjustment
        return self
    }
    
    @discardableResult
    func eisLookToDictateEnabled(_ isLookToDictateEnabled: Bool) -> Self {
        self.isLookToDictateEnabled = isLookToDictateEnabled
        return self
    }
    
    @discardableResult
    func esetShowsCancelButton(_ showsCancelButton: Bool, animated: Bool) -> Self {
        self.setShowsCancelButton(showsCancelButton, animated: animated)
        return self
    }
    @discardableResult
    func esetShowsScope(_ show: Bool, animated animate: Bool) -> Self {
        self.setShowsScope(show, animated: animate)
        return self
    }
    @discardableResult
    func esetBackgroundImage(_ backgroundImage: UIImage?, for barPosition: UIBarPosition, barMetrics: UIBarMetrics) -> Self {
        self.setBackgroundImage(backgroundImage, for: barPosition, barMetrics: barMetrics)
        return self
    }
    @discardableResult
    func esetSearchFieldBackgroundImage(_ backgroundImage: UIImage?, for state: UIControl.State) -> Self {
        self.setSearchFieldBackgroundImage(backgroundImage, for: state)
        return self
    }
    @discardableResult
    func esetImage(_ iconImage: UIImage?, for icon: UISearchBar.Icon, state: UIControl.State) -> Self {
        self.setImage(iconImage, for: icon, state: state)
        return self
    }
    @discardableResult
    func esetScopeBarButtonBackgroundImage(_ backgroundImage: UIImage?, for state: UIControl.State) -> Self {
        self.setScopeBarButtonBackgroundImage(backgroundImage, for: state)
        return self
    }
    @discardableResult
    func esetScopeBarButtonDividerImage(_ dividerImage: UIImage?, forLeftSegmentState leftState: UIControl.State, rightSegmentState rightState: UIControl.State) -> Self {
        self.setScopeBarButtonDividerImage(dividerImage, forLeftSegmentState: leftState, rightSegmentState: rightState)
        return self
    }
    @discardableResult
    func esetScopeBarButtonTitleTextAttributes(_ attributes: [NSAttributedString.Key : Any]?, for state: UIControl.State) -> Self {
        self.setScopeBarButtonTitleTextAttributes(attributes, for: state)
        return self
    }
    @discardableResult
    func esetPositionAdjustment(_ adjustment: UIOffset, for icon: UISearchBar.Icon) -> Self {
        self.setPositionAdjustment(adjustment, for: icon)
        return self
    }
}
