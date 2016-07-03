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
    
    @IBOutlet weak var topSongLabel: UILabel!
    var signInButton: UIButton!
    var createAccountButton: UIButton!
    
    lazy var firebaseClient = {
        return FirebaseClient()
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        // **************   FILLED IN FOR DEBUGGING ************
        firebaseClient.signIn("erichodgins86@gmail.com", password: "123456") { (success, user, error) in
            
            if success {
                print("Signed in user: \(user)")
                let tabBC = self.storyboard?.instantiateViewControllerWithIdentifier("UserProfile")
                //need to grab the NavigationController and then the nav's ViewController for the ProfileVC
                let profileVC = (tabBC?.childViewControllers[0] as! UINavigationController).childViewControllers[0] as! ProfileViewController
                let friendsVC = (tabBC?.childViewControllers[2] as! UINavigationController).childViewControllers[0] as! FriendsViewController
                let topSongsVC = (tabBC?.childViewControllers[1] as! UINavigationController).childViewControllers[0] as! TopSongsViewController
                topSongsVC.user = user
                profileVC.user = user
                friendsVC.user = user
                
                self.presentViewController(tabBC!, animated: true, completion: nil)
            } else {
                // TODO: Alert User an Error has Occcurred signing in
            }
            
        }
    }
    
    func createAccount() {
        firebaseClient.createAccount("erichodgins86@gmail.com", password: "123456") { (success, user, error) in
            if success {
                print("user successfully created.")
            } else {
                //TODO: Alert user account not created.
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
















