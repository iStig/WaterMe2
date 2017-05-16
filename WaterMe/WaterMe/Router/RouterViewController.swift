//
//  RouterViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/11/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import WaterMeData
import WaterMeStore
import UIKit

// Eventual Boot Sequence
/*
 1. Check for Core Data database
    YES - migrate to free realm, present new subscription options
    NO - Go to 2
 
 2. Check realm for icloud logged in user
    YES - Check if there is a realm for Pro photo sync
        YES - Load pro data assuming the user is Pro
        NO - Load app assuming user has Premium cloud sync
    NO - Go to 3
 
 3. Check if there is a local realm on disk
    YES - Assume user is free and load app
    NO - Go to 4
 
 4. Check if there is a receipt
    NO - Assume new free user - create local realm
    YES - Go to 5
 
 5. Read receipt and check for subscription
    YES (subscription present) - Assume receipt is valid, configure realm for subscription level
    NO (subscription not present) - Assume new user - setup for local free realm
*/

class RouterViewController: UIViewController {
    
    class func newVC() -> RouterViewController {
        let sb = UIStoryboard(name: "Router", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        let vc = sb.instantiateInitialViewController() as! RouterViewController
        return vc
    }
    
    @IBAction private func premiumButtonTapped(_ sender: NSObject?) {
        let sender = sender as? UIControl
        sender?.isEnabled = false
        let sl = SubscriptionLoader()
        sl.start() { _ in
            sender?.isEnabled = true
            let vc = SubscriptionChoiceViewController.newVC(subscriptionLoader: sl)
            let navVC = UINavigationController(rootViewController: vc)
            self.show(navVC, sender: sender ?? self)
        }
    }
    
    @IBAction private func localRealm(_ sender: NSObject?) {
        let rc = RealmController(kind: .local)
        print(rc)
        print(rc.realm)
    }
    
    @IBAction private func syncedRealm(_ sender: NSObject?) {
        if let user = RealmController.loggedInUser {
            let rc = RealmController(kind: .synced(user))
            print(rc)
            print(rc.realm)
        } else {
            RealmController.loginWithCloudKit() { result in
                switch result {
                case .error(let error):
                    print(error)
                case .success(let rc):
                    print(rc)
                    print(rc.realm)
                }
                
            }
        }
    }
}
