//
//  FirebaseClient+TopSongs.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-07-08.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import Foundation
import Firebase

extension FirebaseClient {
    func removeFirebaseHandles() {
        //remove all handles on TopSongViewController refresh to prevent multiple calls for song change
        for (id, handle) in firebaseTopSongHandles {
            firDatabaseRef.child("topSongs").child(id).child("songs").removeObserverWithHandle(handle)
        }
        firebaseTopSongHandles.removeAll()
        
        for (id, handle) in firebaseImageUsernameHandles {
            firDatabaseRef.child("users").child(id).removeObserverWithHandle(handle)
        }
        firebaseImageUsernameHandles.removeAll()
    }
    
    typealias DownloadedFriendTopSongs = (friend: Friend, newSongIndexPaths: [NSIndexPath]) -> Void
    
    func downloadFriendsTopSongs(user: FIRUser, delegate: UserInfoUpdating, completionHandler: DownloadedFriendTopSongs) {
        //Refreshing
        removeFirebaseHandles()
        
        // GET all friends id's
        let friendsRef = firDatabaseRef.child("friendsGroup").child("\(user.uid)")
        friendsRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) in
            
            guard snapshot.exists() == true else {
                delegate.endTableViewRefreshing()
                return
            }
            
            let friendsDict = snapshot.value as! [String : AnyObject]
            
            for (section, friend) in friendsDict.enumerate() {
                self.downloadFriendInfo(friend.0, forSection: section, delegate: delegate, completionHandler: completionHandler)
            }
            
            // May need to create a dispatch_group in case of multiple network requests when updating the UI.
            // Also Firebase handles may need to be removed.  But for now it looks okay.
            delegate.endTableViewRefreshing()
        })
    }
    
    func downloadFriendInfo(friendID: String, forSection section: Int, delegate: UserInfoUpdating, completionHandler: DownloadedFriendTopSongs) {
        let usersRef = firDatabaseRef.child("users").child(friendID)
        usersRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) in
            
            guard snapshot.exists() == true else {
                return
            }
            
            let usersDict = snapshot.value as! [String : String]
            let profileName = usersDict["profile-name"]
            let storedImagePath = usersDict["imageFilePath"]
            let imageUpdated = usersDict["image-updated"]
            self.downloadTopSongsForFriend(withID: friendID, username: profileName, imagePath: storedImagePath, lastImageUpdate: imageUpdated, section: section, delegate: delegate, completionHandler: completionHandler)
        })
        
        let handle = usersRef.observeEventType(.ChildChanged, withBlock: {(snapshot) in
            let key = snapshot.key
            
            switch key {
            case "image-updated":
                FirebaseClient.Caches.imageCache.removeImage(forPath: friendID)
                delegate.upatedFriendProfileNameAndImage(friendID, newName: nil)
                return
            case "profile-name":
                let newProfileName = snapshot.value as! String
                delegate.upatedFriendProfileNameAndImage(friendID, newName: newProfileName)
                return
            default:
                print("no idea what changed: \(key)")
            }
        })
        
        firebaseImageUsernameHandles[friendID] = handle
    }
    
    func downloadTopSongsForFriend(withID id: String, username: String?, imagePath: String?, lastImageUpdate: String?, section: Int, delegate: UserInfoUpdating, completionHandler: DownloadedFriendTopSongs) {
        
        let topSongRef = firDatabaseRef.child("topSongs").child(id).child("songs")
        topSongRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) in
            
            guard snapshot.exists() == true else {
                return
            }
            
            let songsArray = snapshot.value as! NSArray
            
            //Format the json Date
            let date: NSDate? = self.makeDateFromString(lastImageUpdate)
            
            var friend = Friend(friendName: username, friendSongs: [], friendID: id, storageImagePath: imagePath, imageUpdate: date)
            var tableViewFriendIndexes = [NSIndexPath]()
            
            let songConverter = SongConverter() // Make a TopSong
            
            var indexPath: NSIndexPath
            for (index, song) in songsArray.enumerate() {
                let songDict = song as! [String : String]
                let topSong = songConverter.generateTopSong(songDict["songArtist"]!, title: songDict["songTitle"]!, rank: "\(index)")
                friend.topSongs?.append(topSong)
                indexPath = NSIndexPath(forRow: friend.topSongs!.count - 1, inSection: section)
                tableViewFriendIndexes.append(indexPath)
            }
            
            completionHandler(friend: friend, newSongIndexPaths: tableViewFriendIndexes)
            
        })
        
        let handle = topSongRef.observeEventType(.ChildChanged, withBlock: {(snapshot) in
            let songDict = snapshot.value as! [String : AnyObject]
            let refArr = "\(snapshot.ref)".componentsSeparatedByString("/")
            let friendID = refArr[refArr.count - 3]
            let songRank = Int(refArr.last!)!
            let artist = songDict["songArtist"] as! String
            let title = songDict["songTitle"] as! String
            
            //Make new Song
            let songConverter = SongConverter()
            let updatedSong = songConverter.generateTopSong(artist, title: title, rank: "\(songRank)")
            
            dispatch_async(dispatch_get_main_queue()) {
                delegate.updateFriendSongChange(friendID, newTopSong: updatedSong, rank: songRank)
            }
        })
        
        self.firebaseTopSongHandles[id] = handle
        
    }

}