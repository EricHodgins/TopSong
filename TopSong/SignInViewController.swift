//
//  SignInViewController.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-06-12.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {
    
    let emailTextfield = UITextField()
    let passwordTextfield = UITextField()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var topSongLabel: UILabel!
    var signInButton: UIButton!
    var createAccountButton: UIButton!
    var forgotPasswordButton: UIButton!
    
    var emailVerticalConstraints = [NSLayoutConstraint]()
    var passwordVerticalConstraints = [NSLayoutConstraint]()
    
    lazy var firebaseClient: FirebaseClient = {
        return FirebaseClient.sharedInstance
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Observe Keyboard notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignInViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignInViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let email = defaults.stringForKey("emailTextField") {
            emailTextfield.text = email
        }
        
        let colorAttribute = UIColor.whiteColor()
        let fontAttribute = UIFont.chalkboardFont(withSize: 25.0)
        topSongLabel.attributedText = NSAttributedString(string: "TopSong", attributes: [NSFontAttributeName: fontAttribute, NSForegroundColorAttributeName: colorAttribute])
        
        setupBackgroundGradient()
        setupButtons()
        setupTextFields()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()

        let topOfKeyboard = view.frame.size.height - keyboardFrame.size.height
        let emailConstantDelta = topOfKeyboard - 110 - 20
        
        if topOfKeyboard - 20 < passwordTextfield.frame.origin.y {
            view.layoutIfNeeded()
            UIView.animateWithDuration(1.0, animations: {
                self.emailVerticalConstraints[0].constant = emailConstantDelta
                self.view.layoutIfNeeded()
            })
        }

    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(1.0) {
            self.emailVerticalConstraints[0].constant = 200
            self.view.layoutIfNeeded()
        }
    }
    
    
    func signIn() {
        guard passwordTextfield.text?.characters.count > 0 && emailTextfield.text?.characters.count > 0 else {
            animateTextFieldsWhenNoTextIsPresent()
            return
        }
        
        activityIndicator.startAnimating()

        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(emailTextfield.text!, forKey: "emailTextField")
        firebaseClient.signIn(emailTextfield.text!, password: passwordTextfield.text!) { (success, user, error) in
            
            if success {
                print("Signed in user: \(user)")
                let tabBC = self.storyboard?.instantiateViewControllerWithIdentifier("UserProfile")
                //need to grab the NavigationController and then the nav's ViewController for the ProfileVC
                let profileVC = (tabBC?.childViewControllers[0] as! UINavigationController).childViewControllers[0] as! ProfileViewController
                let friendsVC = (tabBC?.childViewControllers[2] as! UINavigationController).childViewControllers[0] as! FriendsViewController
                let topSongsVC = (tabBC?.childViewControllers[1] as! UINavigationController).childViewControllers[0] as! TopSongsViewController
                let hitlistVC = (tabBC?.childViewControllers[3] as! UINavigationController).childViewControllers[0] as! HitlistViewController
                topSongsVC.user = user
                profileVC.user = user
                friendsVC.user = user
                hitlistVC.user = user
                self.activityIndicator.stopAnimating()
                
                self.presentViewController(tabBC!, animated: true, completion: nil)
            } else {
                self.activityIndicator.stopAnimating()
                self.showErrorMessage(error, errorTitle: "Could not sign in.")
            }
            
        }
    }
    
    func createAccount() {
        
        let createAccountViewController = storyboard?.instantiateViewControllerWithIdentifier("CreateAccount") as! CreateAccountViewController
        presentViewController(createAccountViewController, animated: true, completion: nil)
        
    }

}


extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if emailTextfield.isFirstResponder() || passwordTextfield.isFirstResponder() {
            view.endEditing(true)
        }
    }
}


//MARK: Reset Password
extension SignInViewController {
    func resetPassword() {
        print("forgot password.")
        activityIndicator.startAnimating()
        FIRAuth.auth()?.sendPasswordResetWithEmail(emailTextfield.text!, completion: { (error) in
            dispatch_async(dispatch_get_main_queue()) {
                self.activityIndicator.stopAnimating()
                guard error == nil else {
                    self.showErrorMessage(error, errorTitle: "Something went wrong..")
                    return
                }
                
                self.showSuccessMessage("Success!", message: "A email will be sent to your inbox shortly with the new password.")
                
            }
        })
    }
}












