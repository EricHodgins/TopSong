//
//  SignInViewController+UI.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-06-27.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit

extension SignInViewController {
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func setupButtons() {
        signInButton = UIButton()
        createAccountButton = UIButton()
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        createAccountButton.translatesAutoresizingMaskIntoConstraints = false
        
        forgotPasswordButton = UIButton()
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        
        signInButton.addTarget(self, action: #selector(SignInViewController.signIn), forControlEvents: .TouchUpInside)
        createAccountButton.addTarget(self, action: #selector(SignInViewController.createAccount), forControlEvents: .TouchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(SignInViewController.askUserIfSureMessage), forControlEvents: .TouchUpInside)
        
        view.addSubview(signInButton)
        view.addSubview(createAccountButton)
        view.addSubview(forgotPasswordButton)
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
        
        let colorAttribute = UIColor().darkBlueAppDesign
        let fontAttribute = UIFont.chalkboardFont(withSize: 20.0)
        
        emailTextfield.defaultTextAttributes = [NSFontAttributeName: fontAttribute, NSForegroundColorAttributeName: colorAttribute]
        passwordTextfield.defaultTextAttributes = [NSFontAttributeName: fontAttribute, NSForegroundColorAttributeName: colorAttribute]
        
        //Sign In Button
        let signInAttributedString = NSAttributedString(string: "Sign In", attributes: [NSFontAttributeName: fontAttribute, NSForegroundColorAttributeName: UIColor.whiteColor()])
        signInButton.setAttributedTitle(signInAttributedString, forState: .Normal)
        
        //Create Account Button
        let createAccountAttributedString = NSAttributedString(string: "Create an Account", attributes: [NSFontAttributeName: fontAttribute, NSForegroundColorAttributeName: UIColor.whiteColor()])
        createAccountButton.setAttributedTitle(createAccountAttributedString, forState: .Normal)
        
        //forgot password Button
        let forgotPasswordAttributedString = NSAttributedString(string: "Forgot Password?", attributes: [NSFontAttributeName: fontAttribute, NSForegroundColorAttributeName: UIColor().darkBlueAppDesign])
        forgotPasswordButton.setAttributedTitle(forgotPasswordAttributedString, forState: .Normal)
        
        
        let views: [String : AnyObject] = [
            "emailView": emailTextfield,
            "passwordView": passwordTextfield,
            "topLayoutGuide": self.topLayoutGuide,
            "signInButton": signInButton,
            "createAccountButton": createAccountButton,
            "forgotPasswordButton": forgotPasswordButton
        ]
        
        let metrics: [String : AnyObject] = [
            "emailHeight": 40,
            "passwordHeight": 40,
            "signInButtonHeight": 20,
            "createAccountButtonHeight": 20,
            "forgotPasswordButtonHeight": 20
        ]
        
        //Email
        emailVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[topLayoutGuide]-200-[emailView(emailHeight)]", options: [], metrics: metrics, views: views)
        view.addConstraints(emailVerticalConstraints)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[emailView]-20-|", options: [], metrics: metrics, views: views))
        //view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[topLayoutGuide]-200-[emailView(emailHeight)]", options: [], metrics: metrics, views: views))
        
        //Password
        passwordVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[emailView]-10-[passwordView(passwordHeight)]", options: [], metrics: metrics, views: views)
        view.addConstraints(passwordVerticalConstraints)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[passwordView]-20-|", options: [], metrics: metrics, views: views))
        //view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[emailView]-10-[passwordView(passwordHeight)]", options: [], metrics: metrics, views: views))
        
        //Sign In Button
        signInButton.centerXAnchor.constraintEqualToAnchor(passwordTextfield.centerXAnchor).active = true
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[passwordView]-15-[signInButton(signInButtonHeight)]", options: [], metrics: metrics, views: views))
        
        //Create Account Button
        createAccountButton.centerXAnchor.constraintEqualToAnchor(passwordTextfield.centerXAnchor).active = true
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[signInButton]-15-[createAccountButton(createAccountButtonHeight)]", options: [], metrics: metrics, views: views))
        
        //Forgot Password Button
        forgotPasswordButton.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[createAccountButton]-40-[forgotPasswordButton(forgotPasswordButtonHeight)]", options: [], metrics: metrics, views: views))
        
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
    
    func askUserIfSureMessage() {
        let alertController = UIAlertController(title: "Are you sure want to reset your password?", message: nil, preferredStyle: .Alert)
        let yesAction = UIAlertAction(title: "YES", style: .Default) { (action) in
            self.resetPassword()
        }
        
        let noAction = UIAlertAction(title: "NO", style: .Default, handler: nil)
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        presentViewController(alertController, animated: true, completion: nil)
        
    }
}























