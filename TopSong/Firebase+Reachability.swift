//
//  Firebase+Reachability.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-08-25.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import Foundation

extension FirebaseClient {
    
    class func internetIsConnected() -> Bool {
        if FirebaseClient.sharedInstance.reachability?.currentReachabilityStatus().rawValue == NotReachable.rawValue {
            return false
        }
        
        return true
    }
}