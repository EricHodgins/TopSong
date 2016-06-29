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
        
        signInButton.addTarget(self, action: #selector(SignInViewController.signIn), forControlEvents: .TouchUpInside)
        let signInAttributedString = NSAttributedString(string: "Sign In", attributes: [NSFontAttributeName: UIFont.chalkboardFont(withSize: 20.0) ,NSForegroundColorAttributeName: UIColor().lightBlueAppDesign])
        signInButton.setAttributedTitle(signInAttributedString, forState: .Highlighted)
        
        let createAccountAttributedString = NSAttributedString(string: "Create an Account", attributes: [NSFontAttributeName: UIFont.chalkboardFont(withSize: 20.0) ,NSForegroundColorAttributeName: UIColor().lightBlueAppDesign])
        createAccountButton.setAttributedTitle(createAccountAttributedString, forState: .Highlighted)
        createAccountButton.addTarget(self, action: #selector(SignInViewController.createAccount), forControlEvents: .TouchUpInside)
        
        view.addSubview(signInButton)
        view.addSubview(createAccountButton)
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
        
        let views: [String : AnyObject] = [
            "emailView": emailTextfield,
            "passwordView": passwordTextfield,
            "topLayoutGuide": self.topLayoutGuide,
            "signInButton": signInButton,
            "createAccountButton": createAccountButton
        ]
        
        let metrics: [String : AnyObject] = [
            "emailHeight": 40,
            "passwordHeight": 40,
            "signInButtonHeight": 20,
            "createAccountButtonHeight": 20
        ]
        
        //Email
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[emailView]-20-|", options: [], metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[topLayoutGuide]-200-[emailView(emailHeight)]", options: [], metrics: metrics, views: views))
        
        //Password
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[passwordView]-20-|", options: [], metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[emailView]-10-[passwordView(passwordHeight)]", options: [], metrics: metrics, views: views))
        
        //Sign In Button
        signInButton.centerXAnchor.constraintEqualToAnchor(passwordTextfield.centerXAnchor).active = true
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[passwordView]-15-[signInButton(signInButtonHeight)]", options: [], metrics: metrics, views: views))
        
        //Create Account Button
        createAccountButton.centerXAnchor.constraintEqualToAnchor(passwordTextfield.centerXAnchor).active = true
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[signInButton]-15-[createAccountButton(createAccountButtonHeight)]", options: [], metrics: metrics, views: views))
        
    }
}