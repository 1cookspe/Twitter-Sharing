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
        // First, check if user is already signed into twitter
        if !TwitterSharing.checkIfUserIsSignedIn() {
            print("No account yet!")
            TwitterSharing.signIn()
        }
        //presentFollow()
        isFollowing {
            self.presentFollow()
        }
        
    }

    @IBAction func shareMilestone(_ sender: Any) {
        TwitterSharing.shareMilestone(vc: self)
    }
    
    func isFollowing(completion: @escaping () -> ()) {  // These API calls are causing the bug, I will look into this function further
        // make sure user is signed in
        if !TwitterSharing.checkIfUserIsSignedIn() {
            TwitterSharing.signIn()
        }
        
        // use callback to get value from closure
        TwitterSharing.checkIfUserIsFollowing(callback: { (_ isFollowing: Bool) in
            // get if user is following from closure
            self.deliverFood(isFollowing: isFollowing, completion: completion)
        })

    }
    
    func deliverFood(isFollowing: Bool, completion: () -> ()) {
        if isFollowing {
            // deliver food to user!
            print("Thanks for following Dawn of Crafting! As a reward, enjoy some free food! Happy crafting!")
        } else {
            // notify user that they must follow Dawn of Crafting
            // present safari view controller to allow user to follow
            // user is already signed into twitter, so we can present the Dawn of Crafting Twitter page to follow
            print("Please ensure that you are following Dawn of Crafting (@DawnOfCrafting) on Twitter to win free food!")
            completion()
        }
    }
    
}

//==========================================================================================================
// MARK: - SFSafariViewControllerDelegate
//==========================================================================================================

extension ViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
        isFollowing {
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

