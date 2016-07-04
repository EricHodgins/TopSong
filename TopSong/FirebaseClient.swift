//
//  FirebaseClient.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-06-26.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import Foundation
import Firebase

public let EAHFirbaseSignInErrorDomain = "com.erichodgins.TopSong.SignInError"
public let SignInError: Int = 10
public let EAHFirbaseCreateAccountErrorDomain = "com.erichodgins.TopSong.CreateAccountError"
public let CreateAccountError: Int = 20

class FirebaseClient {
    
    deinit {
        print("Firebase Client was deinitialized.")
    }
    
    init() {
        print("FirebaseClient was init.")
    }
    
    let firDatabaseRef = FIRDatabase.database().reference()
    let storageRef = FIRStorage.storage().referenceForURL("gs://project-6981864531344520331.appspot.com")
    
    //MARK: Sign In
    func signIn(email: String, password: String, completionHandler: (success: Bool, user: FIRUser?, error: NSError?) -> Void) {
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
            guard error == nil else {
                print("error signing user in: \(error?.localizedDescription)")
                let localizedErrorMessage: String
                switch error!.code {
                case FIRAuthErrorCode.ErrorCodeOperationNotAllowed.rawValue:
                    print("Operation not allowed.")
                    localizedErrorMessage = "Operation not allowed."
                case FIRAuthErrorCode.ErrorCodeUserDisabled.rawValue:
                    print("User disabled.")
                    localizedErrorMessage = "User disabled."
                case FIRAuthErrorCode.ErrorCodeWrongPassword.rawValue:
                    print("Wrong password.")
                    localizedErrorMessage = "Wrong password."
                default:
                    print("\(error)")
                    localizedErrorMessage = "\(error?.localizedDescription)"
                }
                
                let userInfo = [NSLocalizedDescriptionKey: localizedErrorMessage]
                let signInError = NSError(domain: EAHFirbaseSignInErrorDomain, code: SignInError, userInfo: userInfo)
                completionHandler(success: false, user: nil, error: signInError)
                return
            }
            
            //Signed in Successfully
            completionHandler(success: true, user: user, error: nil)
        })
    }
    
    
    func createAccount(email: String, password: String, completionHandler: (success: Bool, user: FIRUser?, error: NSError?) -> Void) {
        
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user, error) in
            guard error == nil else {
                print("error creating account: \(error?.localizedDescription)\n")
                let localizedErrorMessage: String
                switch error!.code {
                case FIRAuthErrorCode.ErrorCodeInvalidEmail.rawValue:
                    print("Invalid email.")
                    localizedErrorMessage = "Invalid email."
                case FIRAuthErrorCode.ErrorCodeEmailAlreadyInUse.rawValue:
                    print("Email already in use")
                    localizedErrorMessage = "Email already in use."
                case FIRAuthErrorCode.ErrorCodeOperationNotAllowed.rawValue:
                    print("Operation now allowed.")
                    localizedErrorMessage = "Operation now allowed."
                case FIRAuthErrorCode.ErrorCodeWeakPassword.rawValue:
                    print("Weak password.")
                    localizedErrorMessage = "Weak password."
                default:
                    print("\(error)")
                    localizedErrorMessage = "\(error?.localizedDescription)"
                }
                
                let userInfo = [NSLocalizedDescriptionKey: localizedErrorMessage]
                let createAccountError = NSError(domain: EAHFirbaseCreateAccountErrorDomain, code: CreateAccountError, userInfo: userInfo)
                completionHandler(success: false, user: nil, error: createAccountError)
                return
            }
            
            completionHandler(success: true, user: user, error: nil)
        })
    }
    
    //MARK: Generate unique username
    func generateUsername(username: String, id: String, completionHandler: (success: Bool, errorMessage: String?) -> Void) {
        
        let registeredUsersRef = firDatabaseRef.child("registered-users").queryOrderedByChild("username").queryEqualToValue(username)
        registeredUsersRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) in
            if snapshot.exists() {
                completionHandler(success: false, errorMessage: "Username is already being used.")
            } else {
                self.firDatabaseRef.child("registered-users").child(id).setValue(["username" : username])
            }
        })
    }
    
    //MARK Downloading
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
    
    
    
    func fetchUserTopSongs(user: FIRUser, completionHanlder: (success: Bool, topSongs: [TopSong]) -> Void) {
        let topSongsRef = firDatabaseRef.child("topSongs").child("\(user.uid)").child("songs")
        topSongsRef.observeEventType(.Value, withBlock: { (snapshot) in
            
            guard snapshot.exists() == true else {
                print("No top songs made.")
                completionHanlder(success: false, topSongs: [])
                return
            }
            
            let songsArray = snapshot.value as! NSArray
            
            let songConverter = SongConverter()
            let topSongsArray = songConverter.getAudioFileFromSystemWithSongsArray(songsArray)
            
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

    
    func fetchUserImage(userId: String, completionHandler: (success: Bool, image: UIImage?) -> Void) {
        let imageRef = storageRef.child("\(userId)\\images\\profile")
        
        let downloadTask = imageRef.dataWithMaxSize(1 * 1024 * 1024) { (imageData, error) in
            guard error == nil else {
                print("Error downloading profile image: \(error?.localizedDescription)")
                completionHandler(success: false, image: nil)
                return
            }

            let image : UIImage = UIImage(data: imageData!)!

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
    
    //MARK: Downloading user's friends top songs
    typealias DownloadedFriendTopSongs = (friend: Friend, newSongIndexPaths: [NSIndexPath]) -> Void
    
    func downloadFriendsTopSongs(user: FIRUser, delegate: TopSongsViewController, completionHandler: DownloadedFriendTopSongs) {
        
        // GET all friends id's
        let friendsRef = firDatabaseRef.child("friendsGroup").child("\(user.uid)")
        friendsRef.observeEventType(.Value, withBlock: {(snapshot) in
            
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
    
    func downloadFriendInfo(friendID: String, forSection section: Int, delegate: TopSongsViewController, completionHandler: DownloadedFriendTopSongs) {
        let usersRef = firDatabaseRef.child("users").child(friendID)
        usersRef.observeEventType(.Value, withBlock: {(snapshot) in
            let usersDict = snapshot.value as! [String : String]
            let profileName = usersDict["profile-name"]
            let storedImagePath = usersDict["imageFilePath"]
            self.downloadTopSongsForFriend(withID: friendID, username: profileName, imagePath: storedImagePath, section: section, delegate: delegate, completionHandler: completionHandler)
        })
    }
    
    func downloadTopSongsForFriend(withID id: String, username: String?, imagePath: String?, section: Int, delegate: TopSongsViewController, completionHandler: DownloadedFriendTopSongs) {
        let topSongRef = firDatabaseRef.child("topSongs").child(id).child("songs")
        topSongRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) in
            let songsArray = snapshot.value as! NSArray
            var friend = Friend(friendName: username, friendSongs: [], friendID: id, storageImagePath: imagePath)
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
        
        topSongRef.observeEventType(.ChildChanged, withBlock: {(snapshot) in
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
    }
    
    
    //MARK: Getting friends for signed in user
    func downloadUsersFriends(userID: String, delegate: FriendsViewController, completionHandler:(friend: Friend) -> Void) {
        let friendsRef = firDatabaseRef.child("friendsGroup").child(userID)
        friendsRef.observeEventType(.Value, withBlock: {(snapshot) in
            
            guard snapshot.exists() == true else {
                delegate.endRefreshing()
                return
            }
            
            let friendsDict = snapshot.value as! [String : AnyObject]
            for friend in friendsDict {
                self.downloadUserFriendInfo(friend.0, delegate: delegate, completionHandler: completionHandler)
            }
            
            delegate.endRefreshing()
        })
    }
    
    func downloadUserFriendInfo(userID: String, delegate: FriendsViewController, completionHandler: (friend: Friend) -> Void) {
        let usersRef = firDatabaseRef.child("users").child(userID)
        usersRef.observeEventType(.Value, withBlock: {(snapshot) in
            let usersDict = snapshot.value as! [String : String]
            let profileName = usersDict["profile-name"]!
            let imagePath = usersDict["imageFilePath"]
            let friend = Friend(friendName: profileName, friendSongs: nil, friendID: userID, storageImagePath: imagePath)
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(friend: friend)
            }
        })
    }
    
    //MARK: Finding friends to add 
    
    func findFriendWithText(id: String, text: String) {
        let friendsRef = firDatabaseRef.child("TEST").queryOrderedByChild("profile-name").queryEqualToValue(text)
        friendsRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) in
            
            
        })
    }
    
    //MARK: Uploading
    
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





























