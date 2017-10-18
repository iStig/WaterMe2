//
//  EmojiPickerViewController.swift
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

import UIKit

class EmojiPickerViewController: StandardCollectionViewController {
    
    class func newVC(emojiChosen: @escaping (String?, UIViewController) -> Void) -> UIViewController {
        let layout = UICollectionViewFlowLayout()
        let vc = EmojiPickerViewController(collectionViewLayout: layout)
        vc.emojiChosen = emojiChosen
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .formSheet
        return navVC
    }
    
    var emojiChosen: ((String?, UIViewController) -> Void)?
    private let data = ["💐", "🌷", "🌹", "🥀", "🌻", "🌼", "🌸", "🌺", "🍏", "🍎", "🍐", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓", "🍈", "🍒", "🍑", "🍍", "🥝", "🥑", "🍅", "🍆", "🥒", "🥕", "🌽", "🌶", "🥔", "🍠", "🌰", "🥜", "🌵", "🎄", "🌲", "🌳", "🌴", "🌱", "🌿", "☘️", "🍀", "🎍", "🎋", "🍃", "🍂", "🍁", "🍄", "🌾", "🥚", "🍳", "🐔", "🐧", "🐤", "🐣", "🐥", "🐓", "🦆", "🦃", "🐇", "🦀", "🦑", "🐙", "🦐", "🍤", "🐠", "🐟", "🐢", "🐍", "🦎", "🐝", "🍯", "🥐", "🍞", "🥖", "🧀", "🥗", "🍣", "🍱", "🍛", "🍚", "☕️", "🍵", "🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯", "🦁", "🐮", "🥛", "🐷", "🐽", "🐸", "🐒", "🦅", "🦉", "🦇", "🐺", "🐗", "🐴", "🦄", "🐛", "🦋", "🐌", "🐚", "🐞", "🐜", "🕷", "🦂", "🐡", "🐬", "🦈", "🐳", "🐋", "🐊", "🐆", "🐅", "🐃", "🐂", "🐄", "🦌", "🐪", "🐫", "🐘", "🦏", "🦍", "🐎", "🐖", "🐐", "🐏", "🐑", "🐕", "🐩", "🐈", "🕊", "🐁", "🐀", "🐿", "🐉", "🐲"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Emoji"
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelButtonTapped(_:)))
        self.navigationItem.rightBarButtonItem = cancel
        self.collectionView?.backgroundColor = .white
        self.collectionView?.alwaysBounceVertical = true
        self.collectionView?.register(EmojiPickerCollectionViewCell.nib, forCellWithReuseIdentifier: EmojiPickerCollectionViewCell.reuseID)
        self.flow?.minimumInteritemSpacing = 0
    }
    
    @objc private func cancelButtonTapped(_ sender: NSObject?) {
        self.emojiChosen?(nil, self)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = self.data[indexPath.row]
        self.emojiChosen?(item, self)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let id = EmojiPickerCollectionViewCell.reuseID
        let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath)
        let cell = _cell as? EmojiPickerCollectionViewCell
        cell?.configure(withEmojiString: self.data[indexPath.row])
        return _cell
    }

    override var columnCount: Int {
        let accessibility = UIApplication.shared.preferredContentSizeCategory.isAccessibilityCategory
        let horizontalClass = self.view.traitCollection.horizontalSizeClass
        switch (horizontalClass, accessibility) {
        case (.unspecified, _), (.regular, _):
            assertionFailure("Hit a size class this VC was not expecting")
            fallthrough
        case (.compact, false):
            return 4
        case (.compact, true):
            return 2
        }
    }

    override var itemHeight: CGFloat {
        return floor((self.collectionView?.bounds.width ?? 0) / CGFloat(self.columnCount))
    }
}
