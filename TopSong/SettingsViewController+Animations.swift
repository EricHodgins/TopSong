//
//  SettingsViewController+Animations.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-08-06.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit

extension SettingsViewController {
    func setupBackgroundGradient() {
        let gradientLayer = CAGradientLayer()
        let lightBlueColor = UIColor().lightBlueAppDesign.CGColor
        let whiteColor = UIColor.whiteColor().CGColor
        gradientLayer.colors = [whiteColor, lightBlueColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = view.frame
        view.layer.insertSublayer(gradientLayer, atIndex: 0)
    }
    
    func animateMusicalNotes() {
        let musicalNotesImageView1 = UIImageView(image: UIImage(named: "MusicalNotes"))
        musicalNotesImageView1.frame = CGRect(x: 55, y: view.frame.size.height, width: 31, height: 35)
        view.insertSubview(musicalNotesImageView1, belowSubview: usernameTextField)
        
        animateMusicalNotesWithBezierCurve(musicalNotesImageView1, animationId: "animation1")
        
        let musicalNotesImageView2 = UIImageView(image: UIImage(named: "MusicalNotes"))
        musicalNotesImageView2.frame = CGRect(x: 55, y: view.frame.size.height, width: 31, height: 35)
        view.insertSubview(musicalNotesImageView2, belowSubview: usernameTextField)
        
        animateMusicalNotesWithBezierCurve(musicalNotesImageView2, animationId: "animation2")
    }
    
    func animateMusicalNotesWithBezierCurve(imageView: UIImageView, animationId: String) {
        let path = UIBezierPath()
        
        let endPoint: CGPoint
        if animationId == "animation1" {
            path.moveToPoint(CGPoint(x: 300, y: view.frame.size.height)) //start
            endPoint = CGPoint(x: cloudImageView.frame.origin.x + 80, y:cloudImageView.frame.origin.y + 30)
            path.addCurveToPoint(endPoint, controlPoint1: CGPoint(x: view.frame.width, y: view.frame.size.height - 100), controlPoint2: CGPoint(x: 0, y: 400))
        } else {
            path.moveToPoint(CGPoint(x: 55, y: view.frame.size.height)) //start
            endPoint = CGPoint(x: cloudImageView.frame.origin.x + 35, y:cloudImageView.frame.origin.y + 47)
            path.addCurveToPoint(endPoint, controlPoint1: CGPoint(x: 0, y: 400), controlPoint2: CGPoint(x: view.frame.width, y: view.frame.size.height - 100))
        }
        
        
        let anim = CAKeyframeAnimation(keyPath: "position")
        anim.setValue(animationId, forKey: "animationId")
        anim.delegate = self
        
        anim.path = path.CGPath
        
        anim.repeatCount = 1
        anim.duration = 4.0
        anim.fillMode = kCAFillModeForwards
        anim.removedOnCompletion = false
        
        imageView.layer.addAnimation(anim, forKey: "path to follow")
    }
    
}
