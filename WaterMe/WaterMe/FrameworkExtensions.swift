//
//  FrameworkExtensions.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/9/17.
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

import SafariServices
import WaterMeStore
import WaterMeData
import UIKit

extension NSString {
    func ranges(of substring: String) -> [NSRange] {
        // make sure we have an immutable copy of the string
        // swiftlint:disable:next force_cast
        let copy = self.copy() as! NSString

        // make a sequence, return NIL to complete the sequence
        return sequence(state: 0) { state -> NSRange? in
            // get the range using the state variable to know the beginning of where to search
            let range = copy.range(of: substring, range: NSRange(location: state, length: copy.length - state))
            // populate the state variable with the location of the last find for the next iteration
            state = NSMaxRange(range)
            // if we ever find NSNotFound for the location, its time to return NIL and end the collection
            return range.location != NSNotFound ? range : nil
        }.map({ $0 })
    }
}

extension SFSafariViewController {
    class func newEmojiOneVC() -> UIViewController {
        let url = URL(string: "https://www.emojione.com")!
        let vc = SFSafariViewController(url: url)
        return vc
    }
}

extension UIApplication {
    func openSettings(completion: ((Bool) -> Void)?) {
        // these don't seem to work any more in iOS 11
        // but there are a lot more here
        // https://github.com/phynet/iOS-URL-Schemes
        let url = URL(string: "App-prefs:")!
        self.open(url, options: [:], completionHandler: completion)
    }

    func openAppSettings(completion: ((Bool) -> Void)?) {
        Analytics.log(viewOperation: .openSettings)
        let url = URL(string: UIApplicationOpenSettingsURLString)!
        self.open(url, options: [:], completionHandler: completion)
    }

    func openWriteReviewPage(completion: ((Bool) -> Void)?) {
        guard let url = PrivateKeys.kReviewAppURL else {
            completion?(false)
            return
        }
        Analytics.log(viewOperation: .openAppStore)
        self.open(url, options: [:], completionHandler: completion)
    }
}

extension AppDelegate {
    var buildNumber: Int {
        let __build = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String
        guard let _build = __build else {
            let message = "Could not retrieve build number from bundle"
            log.error(message)
            assertionFailure(message)
            return -2
        }
        guard let build = Int(_build) else {
            let message = "Could not convert build number into Int"
            log.error(message)
            assertionFailure(message)
            return -1
        }
        return build
    }
}

extension MutableCollection {
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension UIBarButtonItem {
    convenience init(localizedReminderVesselButtonWithTarget target: Any, action: Selector) {
        self.init(title: ReminderVesselMainViewController.LocalizedString.title, style: .done, target: target, action: action)
    }
    convenience init(localizedSettingsButtonWithTarget target: Any, action: Selector) {
        self.init(image: #imageLiteral(resourceName: "TipJar"), style: UIBarButtonItemStyle.plain, target: target, action: action)
        self.accessibilityLabel = SettingsMainViewController.LocalizedString.settingsTitle
    }
    convenience init(localizedDeleteButtonWithTarget target: Any, action: Selector) {
        self.init(title: UIAlertController.LocalizedString.buttonTitleDelete, style: .plain, target: target, action: action)
        self.tintColor = WaterMe.Style.Color.delete
    }
    convenience init(localizedDoneButtonWithTarget target: Any, action: Selector) {
        self.init(barButtonSystemItem: .done, target: target, action: action)
        self.style = .done
    }
    convenience init(localizedAddReminderVesselBBIButtonWithTarget target: Any, action: Selector) {
        self.init(title: UIAlertController.LocalizedString.buttonTitleNewPlant, style: .plain, target: target, action: action)
    }
    func style_updateSettingsButtonInsets(for traitCollection: UITraitCollection) {
        // style values
        let kImageInsetLeadingValue: CGFloat = 18
        let kLandscapeImagePhoneInsetLeadingValue: CGFloat = 24

        // ready to adjust the values
        let imageInsetLeadingValue: CGFloat
        let landscapeImagePhoneInsetLeadingValue: CGFloat

        // adjust the values based on orientation
        switch traitCollection.layoutDirection {
        case .leftToRight, .unspecified:
            imageInsetLeadingValue = kImageInsetLeadingValue * -1
            landscapeImagePhoneInsetLeadingValue = kLandscapeImagePhoneInsetLeadingValue * -1
        case .rightToLeft:
            imageInsetLeadingValue = kImageInsetLeadingValue
            landscapeImagePhoneInsetLeadingValue = kLandscapeImagePhoneInsetLeadingValue
        }

        // reset the values to defaults
        self.imageInsets = .zero
        self.landscapeImagePhoneInsets = .zero

        // put in the new adjusted values
        self.imageInsets.left = imageInsetLeadingValue
        self.landscapeImagePhoneInsets.left = landscapeImagePhoneInsetLeadingValue
    }
}

extension Sequence {
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

class StandardCollectionViewController: UICollectionViewController {

    var flow: UICollectionViewFlowLayout? {
        return self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }

    var columnCountAndItemHeight: (columnCount: Int, itemHeight: CGFloat) {
        return (2, 100)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.contentSizeCategoryDidChange(_:)),
                                               name: .UIContentSizeCategoryDidChange,
                                               object: nil)
    }
    
    @objc private func contentSizeCategoryDidChange(_ aNotification: Any) {
        // TableViewControllers do this automatically
        // Whenever the text size is changed by the user, just reload the collection view
        // then all the cells get their attributed strings re-set
        self.collectionView?.reloadData()
    }

    /// Updates flow layout based on `columnCount` and `itemHeight` properties
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateFlowItemSize()
    }

    private func updateFlowItemSize() {
        let tuple = self.columnCountAndItemHeight
        let columnCount = CGFloat(tuple.columnCount)
        let itemHeight = tuple.itemHeight
        // calculate width of collectionView with insets accounted for
        let width = self.collectionView?.availableContentSize.width ?? 0
        // calculate column width based on usable width of collectionview
        let division = width / columnCount
        self.flow?.itemSize = CGSize(width: floor(division), height: itemHeight)
    }
}

extension UICollectionView {
    func deselectAllItems(animated: Bool) {
        let indexPaths = self.indexPathsForSelectedItems
        indexPaths?.forEach({ self.deselectItem(at: $0, animated: animated) })
    }
    var availableContentSize: CGSize {
        let insets = self.adjustedContentInset
        let width = self.bounds.width - insets.left - insets.right
        let height = self.bounds.height - insets.top - insets.bottom
        return CGSize(width: width, height: height)
    }
}

extension Formatter {
    class var newReminderIntervalFormatter: DateComponentsFormatter {
        let f = DateComponentsFormatter()
        f.allowedUnits = [.month, .weekOfMonth, .day]
        f.unitsStyle = .full
        return f
    }
    class var newTimeAgoFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .full
        f.timeStyle = .none
        f.doesRelativeDateFormatting = true
        return f
    }
    class var newDueDateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .full
        df.timeStyle = .none
        df.doesRelativeDateFormatting = true
        return df
    }
}

extension DateFormatter {
    func timeAgoString(for date: Date?) -> String {
        guard let date = date else { return ReminderMainViewController.LocalizedString.timeAgoLabelNever }
        let dateString = self.string(from: date)
        return dateString
    }
}

extension DateComponentsFormatter {
    func string(forDayInterval interval: Int) -> String {
        let time = TimeInterval(interval) * (60 * 60 * 24)
        let string = self.string(from: time)
        assert(string != nil, "Time Interval Formatter Returned NIL for Interval: \(interval)")
        return string ?? "–"
    }
}

// Alerts for presenting realm errors
extension UIAlertController {
    
    enum ErrorSelection<T: UserFacingError> {
        case cancel, error(T)
    }
    
    convenience init<T>(error: T, completion: ((ErrorSelection<T>) -> Void)?) {
        Analytics.log(viewOperation: .errorAlertRealm)
        self.init(title: error.title, message: error.details, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: LocalizedString.buttonTitleDismiss, style: .cancel, handler: { _ in completion?(.cancel) })
        self.addAction(cancelAction)
        if let actionTitle = error.actionTitle {
            let errorAction = UIAlertAction(title: actionTitle, style: .default) { _ in
                // TODO: Unsafe Assumption
                // The only error that has a button title is to open Settings
                UIApplication.shared.openSettings(completion: nil)
                completion?(.error(error))
            }
            self.addAction(errorAction)
        }
    }
}

// Alerts for presenting User Input Validation Errors
extension UIAlertController {
    
    enum SaveAnywayErrorSelection<T: UserFacingError> {
        case cancel, saveAnyway, error(T)
    }
    
    private convenience init<T>(saveAnywayError error: T, completion: @escaping (SaveAnywayErrorSelection<T>) -> Void) {
        self.init(title: error.title, message: error.details, preferredStyle: .alert)
        if let actionTitle = error.actionTitle {
            let fix = UIAlertAction(title: actionTitle, style: .default, handler: { _ in completion(.error(error)) })
            self.addAction(fix)
        }
        let cancel = UIAlertAction(title: LocalizedString.buttonTitleCancel, style: .cancel, handler: { _ in completion(.cancel) })
        let save = UIAlertAction(title: LocalizedString.buttonTitleSaveAnyway, style: .destructive, handler: { _ in completion(.saveAnyway) })
        self.addAction(cancel)
        self.addAction(save)
    }
    
    private convenience init<T>(actionSheetWithActions actions: [UIAlertAction], cancelSaveCompletion completion: @escaping (SaveAnywayErrorSelection<T>) -> Void) {
        self.init(title: nil, message: LocalizedString.titleUnsolvedIssues, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: LocalizedString.buttonTitleCancel, style: .cancel, handler: { _ in completion(.cancel) })
        let save = UIAlertAction(title: LocalizedString.buttonTitleSaveAnyway, style: .destructive, handler: { _ in completion(.saveAnyway) })
        actions.forEach({ self.addAction($0) })
        self.addAction(cancel)
        self.addAction(save)
    }
    
    class func presentAlertVC<T>(for errors: [T],
                                 over presentingVC: UIViewController,
                                 from barButtonItem: UIBarButtonItem?,
                                 completionHandler completion: @escaping (SaveAnywayErrorSelection<T>) -> Void)
    {
        let errorActions = errors.map() { error -> UIAlertAction in
            let action = UIAlertAction(title: error.title, style: .default) { _ in
                if error.details == nil {
                    // if the alertMessage is NIL, just call the completion handler
                    completion(.error(error))
                } else {
                    // otherwise, make a new alert that gives the user more detailed information
                    let errorAlert = UIAlertController(saveAnywayError: error, completion: completion)
                    presentingVC.present(errorAlert, animated: true, completion: nil)
                }
            }
            return action
        }
        assert(barButtonItem != nil, "Expected to be passed a UIBarButtonItem")
        let actionSheet = UIAlertController(actionSheetWithActions: errorActions, cancelSaveCompletion: completion)
        actionSheet.popoverPresentationController?.barButtonItem = barButtonItem
        presentingVC.present(actionSheet, animated: true, completion: nil)
    }
}

extension UIAlertController {
    class func sourceRect(from view: UIView) -> CGRect {
        let origin = CGPoint(x: view.bounds.size.width / 2, y: view.bounds.size.height / 2)
        return CGRect(origin: origin, size: .zero)
    }
}

extension UIAlertController {
    convenience init(localizedDeleteConfirmationAlertPresentedFrom sender: Either<UIBarButtonItem, UIView>?,
                     userConfirmationHandler confirmed: ((Bool) -> Void)?)
    {
        let style: UIAlertControllerStyle = sender != nil ? .actionSheet : .alert
        self.init(title: nil, message: LocalizedString.deleteAlertMessage, preferredStyle: style)
        let delete = UIAlertAction(title: LocalizedString.buttonTitleDelete, style: .destructive) { _ in
            confirmed?(true)
        }
        let dont = UIAlertAction(title: LocalizedString.buttonTitleDontDelete, style: .cancel) { _ in
            confirmed?(false)
        }
        self.addAction(delete)
        self.addAction(dont)
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
}

extension UIView {
    class func style_animateNormal(_ animations: @escaping () -> Void, completion: @escaping ((Bool) -> Void)) {
        self.animate(withDuration: UIApplication.style_animationDurationNormal,
                     delay: 0,
                     options: [],
                     animations: animations,
                     completion: completion)
    }
    class func style_animateNormal(_ animations: @escaping () -> Void) {
        self.animate(withDuration: UIApplication.style_animationDurationNormal,
                     delay: 0,
                     options: [],
                     animations: animations,
                     completion: nil)
    }
    class func style_animateLong(_ animations: @escaping () -> Void, completion: @escaping ((Bool) -> Void)) {
        self.animate(withDuration: UIApplication.style_animationDurationLong,
                     delay: 0,
                     options: [],
                     animations: animations,
                     completion: completion)
    }
    class func style_animateLong(_ animations: @escaping () -> Void) {
        self.animate(withDuration: UIApplication.style_animationDurationLong,
                     delay: 0,
                     options: [],
                     animations: animations,
                     completion: nil)
    }
}

enum Either<T, U> {
    case left(T), right(U)
}

extension ReminderGedeg: ItemAndSectionable {}
extension UICollectionView: ItemAndSectionable {}
extension UITableView: ItemAndSectionable {

    public func numberOfItems(inSection section: Int) -> Int {
        return self.numberOfRows(inSection: section)
    }

    public var lastIndexPath: IndexPath? {
        let lastSection = self.numberOfSections - 1
        guard lastSection >= 0 else { return nil }
        let lastRow = self.numberOfRows(inSection: lastSection) - 1
        guard lastRow >= 0 else { return nil }
        return IndexPath(row: lastRow, section: lastSection)
    }

    public var allRowsVisible: Bool {
        let visibleIndexPaths = self.indexPathsForVisibleRows ?? []
        guard visibleIndexPaths.isEmpty == false else { return false }
        let numberOfSections = self.dataSource?.numberOfSections?(in: self) ?? 0
        guard numberOfSections > 0 else { return false }
        let numberOfRows = (0..<numberOfSections).reduce(0, +)
        return numberOfRows == visibleIndexPaths.count
    }

    public var visibleRowsSize: CGSize {
        let visibleIndexPaths = self.indexPathsForVisibleRows ?? []
        guard visibleIndexPaths.isEmpty == false else { return .zero }
        let sections = Set(visibleIndexPaths.map({ return $0.section }))
        let sectionHeaderFooterHeights = sections.reduce(0)
        { (lastValue, section) -> CGFloat in
            let headerView = self.headerView(forSection: section)
            let footerView = self.footerView(forSection: section)
            return lastValue +
                (headerView?.frame.height ?? 0)  +
                (footerView?.frame.height ?? 0)
        }
        let rowHeights = visibleIndexPaths.reduce(0)
        { (lastValue, indexPath) -> CGFloat in
            let _cellView = self.cellForRow(at: indexPath)
            guard let cellView = _cellView else { return lastValue }
            return lastValue + cellView.frame.height
        }
        let tableHeaderFooterHeights = { () -> CGFloat in
            let headerView = self.tableHeaderView
            let footerView = self.tableFooterView
            return (headerView?.frame.height ?? 0) + (footerView?.frame.height ?? 0)
        }()
        let width = self.frame.width
        let height = sectionHeaderFooterHeights + rowHeights + tableHeaderFooterHeights
        return CGSize(width: width, height: height)
    }

    public func scrollToBottom(_ animated: Bool) {
        guard let lastIndexPath = self.lastIndexPath else { return }
        self.scrollToRow(at: lastIndexPath, at: .top, animated: animated)
    }
}

extension UIView {
    func maxCornerRadius(withDesiredRadius desiredRadius: CGFloat) -> CGFloat {
        let width = self.frame.width
        let height = self.frame.height
        let restrictingDimension = width < height ? width : height
        let halfRestrictingDimension = restrictingDimension / 2
        if halfRestrictingDimension > desiredRadius {
            return desiredRadius
        } else {
            return halfRestrictingDimension
        }
    }
}
