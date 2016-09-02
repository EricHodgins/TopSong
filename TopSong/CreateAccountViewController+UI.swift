//
//  CreateAccountViewController+UI.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-08-28.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit

extension CreateAccountViewController {
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func setupButtons() {
        createAccountButton = UIButton()
        createAccountButton.translatesAutoresizingMaskIntoConstraints = false
        
        doneButton = UIButton()
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        //doneButton.backgroundColor = UIColor.blackColor()
        
        let fontAttribute = UIFont.chalkboardFont(withSize: 20.0)
        let createAccountAttributedString = NSAttributedString(string: "Create an Account", attributes: [NSFontAttributeName: fontAttribute, NSForegroundColorAttributeName: UIColor.whiteColor()])
        createAccountButton.setAttributedTitle(createAccountAttributedString, forState: .Normal)
        createAccountButton.addTarget(self, action: #selector(CreateAccountViewController.createAccount), forControlEvents: .TouchUpInside)
        
        let doneButtonAttributedString = NSAttributedString(string: "Done", attributes: [NSFontAttributeName: fontAttribute ,NSForegroundColorAttributeName: UIColor.whiteColor()])
        doneButton.setAttributedTitle(doneButtonAttributedString, forState: .Normal)
        doneButton.addTarget(self, action: #selector(CreateAccountViewController.dismissCreateAccountViewController), forControlEvents: .TouchUpInside)

        view.addSubview(createAccountButton)
        view.addSubview(doneButton)
    }
    
    func setupBackgroundGradient() {
        let gradientLayer = CAGradientLayer()
        let lightBlueColor = UIColor(red: 198/255, green: 234/255, blue: 255/255, alpha: 1.0).CGColor
        let brightBlueColor = UIColor(red: 16/255, green: 97/255, blue: 165/255, alpha: 1.0).CGColor
        gradientLayer.colors = [brightBlueColor, lightBlueColor]
        gradientLayer.locations = [0.0, 1.0]
        view.backgroundColor = UIColor.clearColor()
        gradientLayer.frame = view.frame
        view.layer.insertSublayer(gradientLayer, atIndex: 0)
    }
    
    func setupTextFields() {
        view.addSubview(emailTextfield)
        view.addSubview(passwordTextfield)
        view.addSubview(confirmPasswordTextField)
        
        // Email
        emailTextfield.translatesAutoresizingMaskIntoConstraints = false
        emailTextfield.placeholder = "Email"
        emailTextfield.backgroundColor = UIColor.whiteColor()
        emailTextfield.layer.sublayerTransform = CATransform3DMakeTranslation(10.0, 0, 0)
        emailTextfield.keyboardType = .EmailAddress
        emailTextfield.autocapitalizationType = .None
        emailTextfield.autocorrectionType = .No
        emailTextfield.delegate = self
        
        //Password
        passwordTextfield.translatesAutoresizingMaskIntoConstraints = false
        passwordTextfield.placeholder = "Password"
        passwordTextfield.backgroundColor = UIColor.whiteColor()
        passwordTextfield.layer.sublayerTransform = CATransform3DMakeTranslation(10.0, 0, 0)
        passwordTextfield.secureTextEntry = true
        passwordTextfield.delegate = self
        
        //Confirm Password
        confirmPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        confirmPasswordTextField.placeholder = "Confirm Password"
        confirmPasswordTextField.backgroundColor = UIColor.whiteColor()
        confirmPasswordTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10.0, 0, 0)
        confirmPasswordTextField.secureTextEntry = true
        confirmPasswordTextField.delegate = self
        
        let colorAttribute = UIColor().darkBlueAppDesign
        let fontAttribute = UIFont.chalkboardFont(withSize: 20.0)
        
        emailTextfield.defaultTextAttributes = [NSFontAttributeName: fontAttribute, NSForegroundColorAttributeName: colorAttribute]
        passwordTextfield.defaultTextAttributes = [NSFontAttributeName: fontAttribute, NSForegroundColorAttributeName: colorAttribute]
        
        confirmPasswordTextField.defaultTextAttributes = [NSFontAttributeName: fontAttribute, NSForegroundColorAttributeName: colorAttribute]

        
        let views: [String : AnyObject] = [
            "emailView": emailTextfield,
            "passwordView": passwordTextfield,
            "confirmPasswordView": confirmPasswordTextField,
            "topLayoutGuide": self.topLayoutGuide,
            "createAccountButton": createAccountButton
        ]
        
        let metrics: [String : AnyObject] = [
            "emailHeight": 40,
            "passwordHeight": 40,
            "confirmPasswordHeight": 40,
            "createAccountButtonHeight": 20
        ]
        
        //Email
        emailVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[topLayoutGuide]-200-[emailView(emailHeight)]", options: [], metrics: metrics, views: views)
        view.addConstraints(emailVerticalConstraints)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[emailView]-20-|", options: [], metrics: metrics, views: views))
        
        //Password
        passwordVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[emailView]-10-[passwordView(passwordHeight)]", options: [], metrics: metrics, views: views)
        view.addConstraints(passwordVerticalConstraints)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[passwordView]-20-|", options: [], metrics: metrics, views: views))
        
        //Confirm Password
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[confirmPasswordView]-20-|", options: [], metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[passwordView]-10-[confirmPasswordView(confirmPasswordHeight)]", options: [], metrics: metrics, views: views))

        
        //Create Account Button
        createAccountButton.centerXAnchor.constraintEqualToAnchor(passwordTextfield.centerXAnchor).active = true
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[confirmPasswordView]-15-[createAccountButton(createAccountButtonHeight)]", options: [], metrics: metrics, views: views))
        
        //Done Button
        doneButton.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        doneButton.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -20.0).active = true
        doneButton.widthAnchor.constraintEqualToConstant(100).active = true
        doneButton.heightAnchor.constraintEqualToConstant(40.0).active = true
        
    }

    
    //MARK: Animation
    func animateTextFieldsWhenNoTextIsPresent() {
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
    }
    
    //MARK: Error Message Alerts
    
    func showErrorMessage(error: NSError?, errorTitle: String) {
        let message: String
        if let m = error?.localizedDescription {
            message = m
        } else {
            message =  "Unknown error occurred."
        }
        let alertController = UIAlertController(title: errorTitle, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(action)
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    
    //MARK: Success Message
    func showSuccessMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(action)
        self.presentViewController(alertController, animated: true, completion: nil)
    }

}

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    