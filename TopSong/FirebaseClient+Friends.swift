//
//  FirebaseClient+Friends.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-07-08.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import Foundation
import Firebase

extension FirebaseClient {
    //MARK: Getting friends for signed in user
    func downloadUsersFriends(userID: String, delegate: UserInfoUpdating, completionHandler:(friend: Friend) -> Void) {
        
        //check network connection
        if FirebaseClient.internetIsConnected() == false {
            delegate.showNetworkErrorMessage()
            return
        }
        
        
        let friendsRef = firDatabaseRef.child("friendsGroup").child(userID)
        friendsRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) in
            
            guard snapshot.exists() == true else {
                delegate.endTableViewRefreshing()
                return
            }
            
            let friendsDict = snapshot.value as! [String : AnyObject]
            for friend in friendsDict {
                self.downloadUserFriendInfo(friend.0, delegate: delegate, completionHandler: completionHandler)
            }
            
            delegate.endTableViewRefreshing()
        })
    }
    
    func downloadUserFriendInfo(userID: String, delegate: UserInfoUpdating, completionHandler: (friend: Friend) -> Void) {
        let usersRef = firDatabaseRef.child("users").child(userID)
        usersRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) in
            
            guard snapshot.exists() else {
                let friend = Friend(friendName: nil, friendSongs: nil, friendID: userID, storageImagePath: nil, imageUpdate: nil)
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler(friend: friend)
                }
                return
            }
            
            
            let usersDict = snapshot.value as! [String : String]
            let profileName = usersDict["profile-name"]
            let imagePath = usersDict["imageFilePath"]
            let imageUpdate = usersDict["image-updated"]
            
            //Format Date
            let date: NSDate? = self.makeDateFromString(imageUpdate)
            
            let friend = Friend(friendName: profileName, friendSongs: nil, friendID: userID, storageImagePath: imagePath, imageUpdate: date)
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(friend: friend)
            }
        })
        
        usersRef.observeEventType(.ChildChanged, withBlock: {(snapshot) in
            let key = snapshot.key
            switch key {
            case "profile-name":
                let name = snapshot.value as! String
                delegate.upatedFriendProfileNameAndImage(userID, newName: name)
                return
            case "image-updated":
                delegate.upatedFriendProfileNameAndImage(userID, newName: nil)
                return
            default:
                return
            }
        })
    }
    
    //MARK: Finding friends to add
    
    func findFriendWithText(id: String, text: String, delegate: FindFriendsViewController, completionHandler: (friendID: String, username: String) -> Void) {
        
        //check Network connection
        if FirebaseClient.internetIsConnected() == false {
            delegate.showNetworkErrorMessage()
            return
        }
        
        let friendsRef = firDatabaseRef.child("registered-users").queryOrderedByChild("username").queryEqualToValue(text)
        friendsRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) in
            dispatch_async(dispatch_get_main_queue()) {
                if snapshot.exists() {
                    let userDict = snapshot.value as! [String : AnyObject]
                    let friendID = userDict.keys.first!
                    let username = userDict[friendID]!["username"] as! String
                    completionHandler(friendID: friendID ,username: username)
                } else {
                    completionHandler(friendID: "", username: "")
                }
            }
        })
    }
    
    //MARK:Delete Data
    
    func deleteFriendWithID(userID:String, friendID: String) {
        firDatabaseRef.child("friendsGroup").child(userID).child(friendID).removeValue()
    }
    

}