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
    
    lazy var firebaseClient: FirebaseClient = {
        return FirebaseClient.sharedInstance
    }()
    
//    let firebaseClient = FirebaseClient.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    deinit {
        print("SignIn viewcontroller deinit.")
    }
    
    func signIn() {
        guard passwordTextfield.text?.characters.count > 0 && emailTextfield.text?.characters.count > 0 else {
            let animation = CABasicAnimation(keyPath: "position")
            animation.autoreverses = true
            animation.repeatCount = 2
            animation.duration = 0.1
            let toPoint = CGPoint(x: view.frame.width / 2, y: emailTextfield.frame.origin.y + 10) //Doesn't move @ +20
            animation.toValue = NSValue(CGPoint: toPoint)
            emailTextfield.layer.addAnimation(animation, forKey: nil)
            
            let passwordAnimation = CABasicAnimation(keyPath: "position")
            passwordAnimation.autoreverses = true
            passwordAnimation.repeatCount = 2
            passwordAnimation.duration = 0.1
            let toPasswordPoint = CGPoint(x: view.frame.width / 2, y: passwordTextfield.frame.origin.y + 30)
            passwordAnimation.toValue = NSValue(CGPoint: toPasswordPoint)
            passwordTextfield.layer.addAnimation(passwordAnimation, forKey: nil)
            
            return
        }
        
        activityIndicator.startAnimating()
        // **************   FILLED IN FOR DEBUGGING ************
        //erichodgins86@gmail.com
        //hodgins.e@gmail.com
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
                let message: String
                if let m = error?.localizedDescription {
                    message = m
                } else {
                    message =  "Unknown error occurred."
                }
                let alertController = UIAlertController(title: "Could not sign in.", message: message, preferredStyle: .Alert)
                let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(action)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            
        }
    }
    
    func createAccount() {
        activityIndicator.startAnimating()
        firebaseClient.createAccount("erichodgins86@gmail.com", password: "123456") { (success, user, error) in
            if success {
                print("user successfully created.")
                self.activityIndicator.stopAnimating()
            } else {
                //TODO: Alert user account not created.
                self.activityIndicator.stopAnimating()
            }
        }
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
















