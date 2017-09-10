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

class ViewController: UIViewController, SFSafariViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        definesPresentationContext = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func followForFood(_ sender: Any) {
        // First, check if user is already signed into twitter
        if !checkIfUserIsSignedIn() {
            print("No account yet!")
            signIn()
        }
        //presentFollow()
        isFollowing()
    }
    
    func checkIfUserIsSignedIn() -> Bool {
        let store = Twitter.sharedInstance().sessionStore
        let lastSession = store.session()
        var signedIn : Bool = false
        
        if lastSession != nil { // user is already signed into twitter
            signedIn = true
        }
        
        return signedIn
    }
    
    func signIn() {
        Twitter.sharedInstance().logIn(completion: { (session, error) in
            if session != nil { // user successfully signed in
                print("Signed in as \(session?.userName)")
            } else { // user did not sign in
                print("Could not sign in")
            }
        })
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

    @IBAction func shareMilestone(_ sender: Any) {
        if checkIfUserIsSignedIn() {
            var recipeUnlocked: String = "Tea" // this is the recipe or achievement the user unlocked, for testing purposes I will call it "Blue Berry Mash"
        
            // present compose tweet view
            let composer = TWTRComposer()
        
        
            composer.setText("I just discovered the \(recipeUnlocked) recipe in Dawn of Crafting! Download Dawn of Crafting at https://itunes.apple.com/us/app/dawn-of-crafting/id1067104191")
        
            // get screenshot
            UIGraphicsBeginImageContext(view.frame.size)
            view.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
        
            composer.setImage(image)
        
            composer.show(from: self, completion: { (result) in
                if (result == .done) {
                    print("Successfully composed Tweet")
                } else {
                    print("Cancelled composing")
                    print(result)
                }
            })
        } else {
            signIn()
        }
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
        
        isFollowing()
    }
    
    func isFollowing() {  // These API calls are causing the bug, I will look into this function further
        
        // make sure user is signed in
        if !checkIfUserIsSignedIn() {
            signIn()
        }
        
        // use callback to get value from closure
        checkIfUserIsFollowing(callback: { (_ isFollowing: Bool) in
            // get if user is following from closure
            self.deliverFood(isFollowing: isFollowing)
        })

    }
    
    func checkIfUserIsFollowing(callback: @escaping ((_ isFollowing: Bool) -> Void)) {
        let store = Twitter.sharedInstance().sessionStore
        if let userid = store.session()?.userID {
            let client = TWTRAPIClient(userID: userid)
            let friendsEndpoint = "https://api.twitter.com/1.1/friendships/lookup.json"
            let params = ["screen_name": "dawnofcrafting"]
            var clientError : NSError?
            
            let request = client.urlRequest(withMethod: "GET", url: friendsEndpoint, parameters: params, error: &clientError)
            
            client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                do {
                    var followingBool : Bool = false
                    
                    guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [[String: Any]] else {
                        print("error trying to convert data to JSON")
                        return
                    }
                    // this is successful, json is successfully converted to [[String: Any]]
                    
                    for dict in json { //access each dictionary inside of the json
                        if let value = dict["connections"] as? NSArray { //gets the values at "connections" (eg. following, followed_by, etc.)
                            for following in value {
                                if following as! String == "following" {
                                    followingBool = true
                                }
                            }
                        }
                    } 
                    // prints error
                    // Cannot cast "__NSSingleObjectArrayI" to "NSString"
                    callback(followingBool)
                } catch let jsonError as NSError {
                    print("json error: \(jsonError.localizedDescription)")
                    callback(false)
                }
            }
        }
    }
    
    
    func deliverFood(isFollowing: Bool) {
        if isFollowing {
            // deliver food to user!
            print("Thanks for following Dawn of Crafting! As a reward, enjoy some free food! Happy crafting!")
        } else {
            // notify user that they must follow Dawn of Crafting
            // present safari view controller to allow user to follow
            // user is already signed into twitter, so we can present the Dawn of Crafting Twitter page to follow
            print("Please ensure that you are following Dawn of Crafting (@DawnOfCrafting) on Twitter to win free food!")
            presentFollow()
        }
    }
    
    // present alert views based on its title and message
    func presentAlertView(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result: UIAlertAction) -> Void in
            print("OK")
            alertController.dismiss(animated: true, completion: nil)
            
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

