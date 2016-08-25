//
//  FirebaseClient+LoggingIn.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-07-08.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import Foundation
import Firebase

extension FirebaseClient {
    /// For logged in user
    func fetchUsername(id: String, completionHandler: (success: Bool, username: String?) -> Void) {
        let registeresUsersRef = firDatabaseRef.child("registered-users").child(id)
        registeresUsersRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) in
            
            guard snapshot.exists() == true else {
                completionHandler(success: false, username: nil)
                return
            }
            
            let userDict = snapshot.value as! [String : AnyObject]
            let username = userDict["username"] as! String
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: true, username: username)
            }
        })
    }
    
    
    
    func fetchUserTopSongs(user: FIRUser, completionHanlder: (success: Bool, topSongs: [TopSong?]) -> Void) {
        let topSongsRef = firDatabaseRef.child("topSongs").child("\(user.uid)").child("songs")
        topSongsRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            guard snapshot.exists() == true else {
                print("No top songs made.")
                completionHanlder(success: false, topSongs: [])
                return
            }
            
            let songConverter = SongConverter()
            var topSongsArray = [TopSong?]()
            if snapshot.value as? NSArray == nil {
                //For some reason index 2 becomes a Dictionary instead of NSArray
                let songDict = snapshot.value as! [String : AnyObject]
                print(songDict)
                topSongsArray = songConverter.getAudioFileFromSystemWithDictionary(songDict)
            } else {
                let songsArray = snapshot.value as! NSArray
                topSongsArray = songConverter.getAudioFileFromSystemWithSongsArray(songsArray)
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHanlder(success: true, topSongs: topSongsArray)
            }
            
        })
    }
    
    func fetchUsername(user: FIRUser, completionHandler: (success: Bool, username: String) -> Void) {
        let nameRef = firDatabaseRef.child("users").child("\(user.uid)")
        nameRef.observeEventType(.Value, withBlock: { (snapshot) in
            guard snapshot.value != nil && snapshot.exists() == true else {
                print("could not retrived username")
                completionHandler(success: false, username: "")
                return
            }
            
            let user = snapshot.value as! [String : String]
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: true, username: user["profile-name"]!)
            }
        })
    }
    
    
    
    //MARK: Getting Profile Images
    func fetchUserImage(userId: String, completionHandler: (success: Bool, image: UIImage?) -> Void) {
        
        //Check to see if Image is cached already
        if let profileImage = FirebaseClient.Caches.imageCache.imageWithIdentifier(userId) {
            completionHandler(success: true, image: profileImage)
            return
        }
        
        let imageRef = storageRef.child("\(userId)\\images\\profile")
        let downloadTask = imageRef.dataWithMaxSize(1 * 1024 * 1024) { (imageData, error) in
            guard error == nil else {
                print("Error downloading profile image: \(error?.localizedDescription)")
                completionHandler(success: false, image: nil)
                return
            }
            
            let image : UIImage = UIImage(data: imageData!)!
            FirebaseClient.Caches.imageCache.storeImage(image, withIdentifier: userId)
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: true, image: image)
            }
        }
        
        downloadTask.observeStatus(.Progress) { (snapshot) in
            //TODO: Cool animation with this as well?
            //            if let progress = snapshot.progress {
            //                let percentComplete = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
            //                print(percentComplete)
            //            }
        }
    }
    
    
    
    
    //MARK: Uploading/Changing Profile Info
    
    func uploadUserProfileImage(user: FIRUser, image: UIImage, completionHandler: (success: Bool) -> Void) {
        
        //compress Image data
        let imageData : NSData? = UIImageJPEGRepresentation(image, 0.1)
        
        let imageRef = self.storageRef.child("\(user.uid)\\images\\profile")
        
        //upload image data to imageRef path
        let uploadTask = imageRef.putData(imageData!, metadata: nil) { (metadata, error) in
            print("putting image data.")
            guard error == nil else {
                completionHandler(success: false)
                return
            }
        }
        
        uploadTask.observeStatus(.Success) { (snapshot) in
            print("success putting image data.")
            FirebaseClient.Caches.imageCache.removeImage(forPath: user.uid)
            FirebaseClient.Caches.imageCache.storeImage(image, withIdentifier: user.uid)
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateImageUpdated = dateFormatter.stringFromDate(NSDate())
            self.firDatabaseRef.child("users").child(user.uid).updateChildValues(["image-updated": "\(dateImageUpdated)"])
            self.firDatabaseRef.child("users").child(user.uid).updateChildValues(["imageFilePath": "\(imageRef)"])
            completionHandler(success: true)
        }
        
        
        //        uploadTask.observeStatus(.Progress) { (snapshot) in
        //            //TODO: Maybe do some cool animation with this feature while downloading.
        //            if let progress = snapshot.progress {
        //                let percentComplete = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
        //                print(percentComplete)
        //            }
        //        }
    }
    
    
    func updateTopSong(user: FIRUser, indexPath: NSIndexPath, song: TopSong) {
        firDatabaseRef.child("topSongs").child(user.uid).child("songs").child("\(indexPath.row)").setValue(["songTitle": song.title, "songArtist": song.artist])
    }
    
    func updateUsername(user: FIRUser, name: String) {
        firDatabaseRef.child("users").child(user.uid).updateChildValues(["profile-name": name])
    }

}