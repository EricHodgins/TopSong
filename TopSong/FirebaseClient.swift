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
    
    //Singleton
    static let sharedInstance = FirebaseClient()
    
    //Store Handles.  Need to remove on refresh.  Or Multiple Network calls are made for the same Firebase path, which is uneccessary and a waste of network data.
    var firebaseTopSongHandles = [String : UInt]()
    var firebaseImageUsernameHandles = [String : UInt]()
    
    //Shared Image Cache
    struct Caches {
        static let imageCache = ImageCache()
    }
    
    deinit {
        print("Firebase Client was deinitialized.")
    }
    
    private init() {
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

    
    //MARK:Delete Data
    
    func deleteFriendWithID(userID:String, friendID: String) {
        firDatabaseRef.child("friendsGroup").child(userID).child(friendID).removeValue()
    }
    
}





























