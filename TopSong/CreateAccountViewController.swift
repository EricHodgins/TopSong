//
//  CreateAccountViewController.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-08-28.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController {
    
    let emailTextfield = UITextField()
    let passwordTextfield = UITextField()
    let confirmPasswordTextField = UITextField()
    
    var emailVerticalConstraints = [NSLayoutConstraint]()
    var passwordVerticalConstraints = [NSLayoutConstraint]()
    
    var createAccountButton: UIButton!
    var doneButton: UIButton!
    
    lazy var firebaseClient: FirebaseClient = {
        return FirebaseClient.sharedInstance
    }()

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupButtons()
        setupTextFields()
        setupBackgroundGradient()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createAccount() {
        guard passwordTextfield.text?.characters.count > 0 && emailTextfield.text?.characters.count > 0 else {
            animateTextFieldsWhenNoTextIsPresent()
            return
        }
        
        guard passwordTextfield.text == confirmPasswordTextField.text else {
            let error = NSError(domain: "CreateAccount", code: 0, userInfo: [NSLocalizedDescriptionKey : "Password Mismatch Error"])
            showErrorMessage(error, errorTitle: "Sorry, retry.  Password didn't match confirmation password.")
            return
        }

        activityIndicator.startAnimating()
        firebaseClient.createAccount(emailTextfield.text!, password: passwordTextfield.text!) { (success, user, error) in
            if success {
                self.activityIndicator.stopAnimating()
                self.showSuccessMessage("Awesome! Account Created.", message: "Keep care of your password.")
            } else {
                self.activityIndicator.stopAnimating()
                self.showErrorMessage(error, errorTitle: "Could not create account.")
            }
        }
    }
    
    
    func dismissCreateAccountViewController() {
        dismissViewControllerAnimated(true, completion: nil)
    }

}






extension CreateAccountViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if emailTextfield.isFirstResponder() || passwordTextfield.isFirstResponder() || confirmPasswordTextField.isFirstResponder() {
            view.endEditing(true)
        }
    }
}

