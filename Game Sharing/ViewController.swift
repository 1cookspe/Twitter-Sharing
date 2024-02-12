//
//  ViewController.swift
//  Game Sharing
//
//  Created by Spencer Cook on 2017-07-27.
//  Copyright © 2017 Spencer Cook. All rights reserved.
//

import UIKit
import TwitterKit
import SafariServices

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
    }

    @IBAction func followForFood(_ sender: Any) {
        TwitterSharing.followForFood {
            self.presentFollow()
        }
    }

    @IBAction func shareMilestone(_ sender: Any) {
        TwitterSharing.shareMilestone(vc: self)
    }
    
}

//==========================================================================================================
// MARK: - SFSafariViewControllerDelegate
//==========================================================================================================

extension ViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
        TwitterSharing.isFollowing {
            self.presentFollow()
        }
    }
    
    func presentFollow() {
        print("PRESENT FOLLOW ---------------------------------------------------------")
        let safariViewController = SFSafariViewController(url: URL(string: "http://www.twitter.com/DawnOfCrafting")!)
        safariViewController.delegate = self
        if presentedViewController == nil {
            self.present(safariViewController, animated: true, completion: nil)
        } else {
            self.dismiss(animated: false) { () -> Void in
                self.present(safariViewController, animated: true, completion: nil)
            }
        }
    }
}

