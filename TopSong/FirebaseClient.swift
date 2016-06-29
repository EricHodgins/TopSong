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
    
    //MARK Downloading
    func fetchUserTopSongs(user: FIRUser, completionHanlder: (success: Bool, topSongs: [TopSong]) -> Void) {
        let topSongsRef = firDatabaseRef.child("topSongs").child("\(user.uid)").child("songs")
        topSongsRef.observeEventType(.Value, withBlock: { (snapshot) in
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
            guard snapshot.value != nil else {
                print("could not retrived username")
                completionHandler(success: false, username: "")
                return
            }
            
            let username = snapshot.value as! [String : String]
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(success: true, username: username["username"]!)
            }
        })
    }

    
    func fetchUserImage(user: FIRUser, completionHandler: (success: Bool, image: UIImage?) -> Void) {
        let imageRef = storageRef.child("\(user.uid)\\images\\profile")
        
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
        firDatabaseRef.child("users").child(user.uid).updateChildValues(["username": name])
    }
    
}





























