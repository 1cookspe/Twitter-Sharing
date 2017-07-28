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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func followForFood(_ sender: Any) {
        // First, check if user is already signed into twitter
        let store = Twitter.sharedInstance().sessionStore
        let lastSession = store.session()
        
        if lastSession != nil { // user has already signed into twitter
            print("Signed in!")
            presentFollow()
        } else { // not signed in yet (so we will sign them in!)
            print("No account yet!")
            signIn()
        }
    }
    
    func signIn() {
        Twitter.sharedInstance().logIn(completion: { (session, error) in
            if session != nil { // user successfully signed in
                print("Signed in as \(session?.userName)")
                self.presentFollow()
            } else { // user did not sign in
                print("Could not sign in")
            }
        })
    }
    
    func presentFollow() {
        print("PRESENT FOLLOW ---------------------------------------------------------")
        let safariViewController = SFSafariViewController(url: URL(string: "http://www.twitter.com/DawnOfCrafting")!)
        safariViewController.delegate = self
        self.present(safariViewController, animated: true, completion: nil)
    }

    @IBAction func shareMilestone(_ sender: Any) {
        var recipeUnlocked: String = "Blue Berry Mash" // this is the recipe or achievement the user unlocked, for testing purposes I will call it "Blue Berry Mash"
        
        // present compose tweet view
        let composer = TWTRComposer()
        
        
        composer.setText("I just unlocked the \(recipeUnlocked) recipe in Dawn of Crafting! Download now at https://itunes.apple.com/us/app/dawn-of-crafting/id1067104191")
        
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
            }
        })
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
        
        // Once the user closes Twitter, check that the user is following Dawn of Crafting
        if isFollowing() {
            // give user food
            print("Have some food!")
            // show to user that they have earned food (in the actual game, they will receive actual game food, but for testing purposes I will only show them an alert view that they win food)
            presentAlertView(title: "You win!", message: "Congratulations, enjoy your free food!")
            
        } else {
            // display error to user that they must follow
            print("Did not follow")
            
            presentAlertView(title: "Must follow for food!", message: "You must follow the Dawn of Crafting Twitter account @DawnOfCrafting to win food! Please try again!")
        }
    }
    
    func isFollowing() -> Bool {  // These API calls are causing the bug, I will look into this function further
        var isFollowing: Bool = false // initial set "following" to false, then turn it to true if user is following Dawn of Crafting
        
        let client = TWTRAPIClient()
        let friendsEndpoint = "https://api.twitter.com/1.1/friendships/lookup.json"
        let params = ["screen_name": "dawnofcrafting"]
        var clientError : NSError?
        
        let request = client.urlRequest(withMethod: "GET", url: friendsEndpoint, parameters: params, error: &clientError)
        
        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            if connectionError != nil {
                print("Error: \(connectionError)")
            }
            
            do {
                // break down users json to determine whether or not the user is following Dawn of Crafting
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                // JSON with object root
                if let dictionary = json as? [String: Any] {
                    if let connections = dictionary["connections"] as? [String] {
                        // loop through connections, check if "following" is a connection
                        // meaning that the authenticated user is following Dawn of Crafting
                        for connection in connections {
                            if connection == "following" { // user is following Dawn of Crafting
                                isFollowing = true
                                // end loop
                                break
                            }
                        }
                    }
                }
                print("json: \(json)")
            } catch let jsonError as NSError {
                print("json error: \(jsonError.localizedDescription)")
            }
        }

        return isFollowing
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

