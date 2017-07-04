//
//  StyleExtensions.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 6/3/17.
//  Copyright © 2017 Saturday Apps.
//
//  This file is part of WaterMe.  Simple Plant Watering Reminders for iOS.
//
//  WaterMe is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  WaterMe is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with WaterMe.  If not, see <http://www.gnu.org/licenses/>.
//

import WaterMeData
import UIKit

extension UITableViewCell {
    static let style_labelCellTopPadding: CGFloat = 12
    static let style_labelCellBottomPadding: CGFloat = 10
    static let style_labelCellLeadingPadding: CGFloat = 20
    static let style_labelCellTrailingPadding: CGFloat = 20
    
    static let style_textFieldCellTopPadding: CGFloat = 8
    static let style_textFieldCellBottomPadding: CGFloat = 6
    static let style_textFieldCellLeadingPadding: CGFloat = 20
    static let style_textFieldCellTrailingPadding: CGFloat = 20
}

extension UILabel {
    func style_reminderVesselNameLabel() {
        self.adjustsFontForContentSizeCategory = true
        self.font = UIFont.preferredFont(forTextStyle: .title3)
    }
    func style_emojiLargeDisplayLabel() {
        self.font = UIFont.systemFont(ofSize: 60)
        self.lineBreakMode = .byClipping
        self.clipsToBounds = true
    }
    func style_emojiSmallDisplayLabel() {
        self.font = UIFont.systemFont(ofSize: 32)
        self.lineBreakMode = .byClipping
        self.clipsToBounds = true
    }
}

extension UITextField {
    func style_tableViewCellTextInput() {
        self.adjustsFontForContentSizeCategory = true
        self.font = UIFont.preferredFont(forTextStyle: .body)
        self.textColor = .black
    }
}

extension UILabel {
    func style_selectableTableViewCell() {
        self.adjustsFontForContentSizeCategory = true
        self.font = style_tableViewCellFont
        self.textColor = style_selectableTableViewCellColor
    }
    func style_readOnlyTableViewCell() {
        self.adjustsFontForContentSizeCategory = true
        self.font = style_tableViewCellFont
        self.textColor = style_readOnlyTableViewCellColor
    }
}

fileprivate var style_tableViewCellFont: UIFont {
    return UIFont.preferredFont(forTextStyle: .callout)
}

fileprivate var style_readOnlyTableViewCellColor: UIColor {
    return .gray
}

fileprivate var style_selectableTableViewCellColor: UIColor {
    return .black
}

extension NSAttributedString {
    enum Style {
        case selectableTableViewCell, readOnlyTableViewCell
    }
    
    convenience init(string: String, style: Style) {
        let attributes: [String : Any]
        switch style {
        case .readOnlyTableViewCell:
            attributes = [
                NSFontAttributeName : style_tableViewCellFont,
                NSForegroundColorAttributeName : style_readOnlyTableViewCellColor
            ]
        case .selectableTableViewCell:
            attributes = [
                NSFontAttributeName : style_tableViewCellFont,
                NSForegroundColorAttributeName : style_selectableTableViewCellColor
            ]
        }
        self.init(string: string, attributes: attributes)
    }
}
