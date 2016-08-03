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
    
    var user: FIRUser?
    let firebaseClient = FirebaseClient.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            //presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            view.window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
        } catch let error as NSError {
            print("could not logout user: \(error)")
        }
    }
}

extension SettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
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
    
    func generateUsername(name: String) {
        firebaseClient.generateUsername(name, id: user!.uid) { (success, errorMessage) in
            if !success {
                //TODO: Notify user unsuccessful
                print(errorMessage)
            }
        }
    }
    
}