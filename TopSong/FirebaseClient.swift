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
            
            //Signed Successfully
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
    
}





























