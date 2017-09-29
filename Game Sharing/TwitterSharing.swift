//
//  TwitterSharing.swift
//  Game Sharing
//
//  Created by Goktug Yilmaz on 29/9/17.
//  Copyright © 2017 Spencer Cook. All rights reserved.
//

import TwitterKit

struct TwitterSharing {
    static func start() {
        Twitter.sharedInstance().start(withConsumerKey:"ohT2U2785tOL7uplny3erDHed", consumerSecret:"wI5oWXW3Kmu6gqSbNmqBCw8yMiEElOzYU8x0Q60VzEqhUIXl0q")
    }
    
    static func openTwitterApp(_ app: UIApplication, url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return Twitter.sharedInstance().application(app, open: url, options: options)
    }
    
    static func signIn() {
        Twitter.sharedInstance().logIn(completion: { (session, error) in
            if session != nil { // user successfully signed in
                print("Signed in as \(String(describing: session?.userName))")
            } else { // user did not sign in
                print("Could not sign in")
            }
        })
    }

    static func checkIfUserIsSignedIn() -> Bool {
        let store = Twitter.sharedInstance().sessionStore
        let lastSession = store.session()
        var signedIn : Bool = false
        
        if lastSession != nil { // user is already signed into twitter
            signedIn = true
        }
        
        return signedIn
    }

    static func checkIfUserIsFollowing(callback: @escaping ((_ isFollowing: Bool) -> Void)) {
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

    static func shareMilestone(vc: UIViewController) {
        if TwitterSharing.checkIfUserIsSignedIn() {
            let recipeUnlocked: String = "Tea" // this is the recipe or achievement the user unlocked, for testing purposes I will call it "Blue Berry Mash"
            
            // present compose tweet view
            let composer = TWTRComposer()
            
            composer.setText("I just discovered the \(recipeUnlocked) recipe in Dawn of Crafting! Download Dawn of Crafting at https://itunes.apple.com/us/app/dawn-of-crafting/id1067104191")
            
            // get screenshot
            UIGraphicsBeginImageContext(vc.view.frame.size)
            vc.view.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            
            composer.setImage(image)
            
            composer.show(from: vc, completion: { (result) in
                if (result == .done) {
                    print("Successfully composed Tweet")
                } else {
                    print("Cancelled composing")
                    print(result)
                }
            })
        } else {
            TwitterSharing.signIn()
        }
    }
    
}









