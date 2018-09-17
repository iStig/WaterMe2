//
//  ReminderNotificationAlert.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 6/1/18.
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

import UserNotifications
import UIKit

extension UIAlertController {

    enum PermissionSelection {
        case denied, allowed, cancel
    }

    convenience init?(newPermissionAlertIfNeededPresentedFrom sender: Either<UIBarButtonItem, UIView>?,
                      selectionCompletionHandler selection: ((PermissionSelection) -> Void)?)
    {
        let nc = UNUserNotificationCenter.current()
        let ud = UserDefaults.standard
        let authorizationStatus = nc.settings.authorizationStatus
        let userAskedToBeAsked = ud.askForNotifications
        let style: UIAlertControllerStyle = sender != nil ? .actionSheet : .alert
        switch (authorizationStatus, userAskedToBeAsked) {
        case (.notDetermined, true):
            self.init(newRequestPermissionAlertWithStyle: style, selectionCompletionHandler: selection)
        case (.denied, true):
            self.init(newPermissionDeniedAlertWithStyle: style, selectionCompletionHandler: selection)
        default:
            return nil
        }
        guard let sender = sender else { return }
        switch sender {
        case .left(let bbi):
            self.popoverPresentationController?.barButtonItem = bbi
        case .right(let view):
            self.popoverPresentationController?.sourceView = view
            self.popoverPresentationController?.sourceRect = type(of: self).sourceRect(from: view)
            self.popoverPresentationController?.permittedArrowDirections = [.up, .down]
        }
    }

    private convenience init(newRequestPermissionAlertWithStyle style: UIAlertControllerStyle,
                             selectionCompletionHandler selection: ((PermissionSelection) -> Void)?)
    {
        self.init(title: LocalizedString.newPermissionTitle,
                  message: LocalizedString.newPermissionMessage,
                  preferredStyle: style)
        let ud = UserDefaults.standard
        let yes = UIAlertAction(title: LocalizedString.newPermissionButtonTitleSendNotifications, style: .default) { _ in
            ud.askForNotifications = true
            UNUserNotificationCenter.current().requestAuthorizationIfNeeded() { permitted in
                switch permitted {
                case true:
                    Analytics.log(event: Analytics.NotificationPermission.permissionGranted)
                    AppDelegate.shared.reminderObserver?.notificationPermissionsMayHaveChanged()
                    selection?(.allowed)
                case false:
                    Analytics.log(event: Analytics.NotificationPermission.permissionDenied)
                    selection?(.denied)
                }
            }
        }
        let no = UIAlertAction(title: LocalizedString.newPermissionButtonTitleDontSendNotifications, style: .destructive) { _ in
            Analytics.log(event: Analytics.NotificationPermission.permissionDenied)
            ud.askForNotifications = false
            selection?(.denied)
        }
        let cancel = UIAlertAction(title: LocalizedString.buttonTitleDismiss, style: .cancel) { _ in
            Analytics.log(event: Analytics.NotificationPermission.permissionIgnored)
            ud.askForNotifications = true
            selection?(.cancel)
        }
        self.addAction(yes)
        self.addAction(no)
        self.addAction(cancel)
    }
    private convenience init(newPermissionDeniedAlertWithStyle style: UIAlertControllerStyle,
                             selectionCompletionHandler selection: ((PermissionSelection) -> Void)?)
    {
        self.init(title: LocalizedString.permissionDeniedAlertTitle,
                  message: LocalizedString.permissionDeniedAlertMessage,
                  preferredStyle: style)
        let ud = UserDefaults.standard
        let settings = UIAlertAction(title: SettingsMainViewController.LocalizedString.settingsTitle, style: .default) { _ in
            ud.askForNotifications = true
            UIApplication.shared.openSettings() { _ in
                selection?(.cancel)
            }
        }
        let dontAsk = UIAlertAction(title: LocalizedString.buttonTitleDontAskAgain, style: .destructive) { _ in
            ud.askForNotifications = false
            selection?(.denied)
        }
        let cancel = UIAlertAction(title: LocalizedString.buttonTitleDismiss, style: .cancel) { _ in
            ud.askForNotifications = true
            selection?(.cancel)
        }
        self.addAction(settings)
        self.addAction(dontAsk)
        self.addAction(cancel)
    }
}
