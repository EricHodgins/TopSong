//
//  Firebase+Reachability.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-08-25.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import Foundation
import Firebase

extension FirebaseClient {
    
    class func internetIsConnected() -> Bool {
        if FirebaseClient.sharedInstance.reachability?.currentReachabilityStatus().rawValue == NotReachable.rawValue {
            return false
        }
        
        let connectedRef = FIRDatabase.database().referenceWithPath(".info/connected")
        connectedRef.observeEventType(.Value, withBlock: {(connected) in
            let status = connected.value as? Bool
            print("Connected Ref Changed: \(status)")
            if let boolean = status where boolean == false {
                NSNotificationCenter.defaultCenter().postNotificationName(networkErrorNotificationKey, object: nil)
            }
        })
        
        return true
    }
}