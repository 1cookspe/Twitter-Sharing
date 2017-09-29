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
    
    
    
}









