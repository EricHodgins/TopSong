//
//  SettingsViewController.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-07-18.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {

    @IBOutlet weak var usernameDescriptionLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cloudImageView: UIImageView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    var presentingAlertMessage: Bool = false
    
    var user: FIRUser?
    let firebaseClient = FirebaseClient.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let username = defaults.objectForKey("username/\(user!.uid)") as? String {
            usernameTextField.text = username
        }
        
        // Username
        downloadUsername()
        usernameTextField.delegate = self
        usernameTextField.attributedPlaceholder = UIDesign.lightStyleAttributedString("Username", fontSize: 18.0)
        usernameTextField.defaultTextAttributes = [NSFontAttributeName: UIFont.chalkboardFont(withSize: 18.0), NSForegroundColorAttributeName: UIColor().lightBlueAppDesign]
        usernameTextField.textAlignment = .Center
        
        //Username Description
        usernameDescriptionLabel.attributedText = UIDesign.darkStyleAttributedString("Pick a username so friends can find you!", fontSize: 18.0)
        
        //Logout Button
        let attributedString = UIDesign.highlightedAttributedString("Logout", fontSize: 21.0)
        let doneAttributedString = UIDesign.darkStyleAttributedString("Done", fontSize: 21.0)
        logoutButton.setAttributedTitle(attributedString, forState: .Normal)
        doneButton.setAttributedTitle(doneAttributedString, forState: .Normal)
        
        setupBackgroundGradient()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingsViewController.showNetworkErrorMessage), name: networkErrorNotificationKey, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        animateMusicalNotes()
    }
    
    //MARK: Download username
    func downloadUsername() {
        firebaseClient.fetchUsername(user!.uid) { (success, username) in
            if success {
                self.usernameTextField.text = username
            }
        }
    }

    @IBAction func doneButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func logoutButtonPressed(sender: AnyObject) {
        print("logging out")
        do {
            try FIRAuth.auth()?.signOut()
            view.window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
        } catch let error as NSError {
            print("could not logout user: \(error)")
        }
    }
}

extension SettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(textField.text!, forKey: "username/\(user!.uid)")
        
        generateUsername(textField.text!)
        textField.resignFirstResponder()
        
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if usernameTextField.isFirstResponder() {
            generateUsername(usernameTextField.text!)
            usernameTextField.resignFirstResponder()
        }
    }
    
    //MARK: Upload username
    func generateUsername(name: String) {
        activityView.startAnimating()
        firebaseClient.generateUsername(name, id: user!.uid) { (success, errorMessage) in
            if !success {
                self.showMessage("Failed to create username", message: errorMessage!)
            } else {
                self.showMessage("Success!", message: "Username created.")
            }
            
            self.activityView.stopAnimating()
        }
        
        
    }
    
    func showNetworkErrorMessage() {
        print("show network error message.")
            if presentingAlertMessage == false {
            dispatch_async(dispatch_get_main_queue()) {
                self.activityView.stopAnimating()
                self.showMessage("Network Error", message: "Looks like there is a network problem. Check your connection.")
            }
        }
    }
    
    func showMessage(title: String, message: String?) {
        presentingAlertMessage = true
        let errorMessage: String
        if message != nil {
            errorMessage = message!
        } else {
            errorMessage = ""
        }
        
        let alertController = UIAlertController(title: title, message: errorMessage, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default) { (action) in
            self.presentingAlertMessage = false
        }
            
        alertController.addAction(action)
        
        self.presentViewController(alertController, animated: true, completion: nil)
        print(errorMessage)
    }
}














