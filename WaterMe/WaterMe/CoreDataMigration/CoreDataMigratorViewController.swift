//
//  CoreDataMigratorViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 29/12/17.
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

extension CoreDataMigratorViewController {
    enum LocalizedString {
        static let title =
            NSLocalizedString("WaterMe 2",
                              comment: "MigratorScreen: Title: Name of the app.")
        static let subtitle =
            NSLocalizedString("Data Migration",
                              comment: "MigratorScreen: Subtitle: Explains what is happening on the screen.")
        static let body =
            NSLocalizedString("In order to upgrade to WaterMe 2, a one time data migration is required.",
                              comment: "MigratorScreen: Body: Body text that explains the one time migration needed to upgrade to the new WaterMe.")
        static let migrateButtonTitle =
            NSLocalizedString("Start Migration",
                              comment: "MigratorScreen: Start Button Title: When the user clicks this button the migration starts.")
        static let cancelButtonTitle =
            NSLocalizedString("Skip for Now",
                              comment: "MigratorScreen: Cancel Button Title: When the user clicks this button the screen is dismissed and the migration does not happen, but next time the app is started, it will ask again.")
        static let deleteButtonTitle =
            NSLocalizedString("Don't Migrate My Plants",
                              comment: "MigratorScreen: Delete Button Title: When the user clicks this button, the screen is dismissed and it will never appear again and they will not have access to their previous plants. This action is destructive.")
    }
}

class CoreDataMigratorViewController: UIViewController, HasBasicController {

    class func newVC(migrator: CoreDataMigratable, basicRC: BasicController, completion: @escaping (UIViewController) -> Void) -> UIViewController {
        let sb = UIStoryboard(name: "CoreDataMigration", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        var vc = sb.instantiateInitialViewController() as! CoreDataMigratorViewController
        vc.completionHandler = completion
        vc.configure(with: basicRC)
        vc.migrator = migrator
        return vc
    }

    @IBOutlet private weak var contentView: UIView?
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var subtitleLabel: UILabel?
    @IBOutlet private weak var bodyLabel: UILabel?
    @IBOutlet private weak var progressView: UIProgressView?
    @IBOutlet private weak var migrateButton: UIButton?
    @IBOutlet private weak var cancelButton: UIButton?
    @IBOutlet private weak var deleteButton: UIButton?

    private var completionHandler: ((UIViewController) -> Void)!
    private var migrator: CoreDataMigratable!
    var basicRC: BasicController?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.contentView?.layer.cornerRadius = UIApplication.style_cornerRadius
        self.progressView?.observedProgress = self.migrator.progress
    }

    private func configureAttributedText() {
        let tintColor = self.view.tintColor ?? .black
        self.titleLabel?.attributedText = NSAttributedString(string: LocalizedString.title, style: .migratorTitle)
        self.subtitleLabel?.attributedText = NSAttributedString(string: LocalizedString.subtitle, style: .migratorSubtitle)
        self.bodyLabel?.attributedText = NSAttributedString(string: LocalizedString.body, style: .migratorBody)
        self.migrateButton?.setAttributedTitle(NSAttributedString(string: LocalizedString.migrateButtonTitle, style: .migratorPrimaryButton(tintColor)), for: .normal)
        self.cancelButton?.setAttributedTitle(NSAttributedString(string: LocalizedString.cancelButtonTitle, style: .migratorSecondaryButton(tintColor)), for: .normal)
        self.deleteButton?.setAttributedTitle(NSAttributedString(string: LocalizedString.deleteButtonTitle, style: .migratorSecondaryButton(tintColor)), for: .normal)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.configureAttributedText()
    }

}
