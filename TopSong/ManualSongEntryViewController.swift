//
//  ManualSongEntryViewController.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-09-01.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit

class ManualSongEntryViewController: UIViewController {
    
    weak var delegate: ProfileViewController?
    
    var artistTextField = UITextField()
    var titleTextField = UITextField()
    var doneButton: UIButton!
    var cancelButton: UIButton!
    var pickedNumberAtIndexPath: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
        view.insertSubview(blurEffectView, atIndex: 0)
        
        setupButtons()
        setupTextFields()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
    }

    
    func donePressed() {
        guard artistTextField.text != nil && titleTextField.text != nil else {
            return
        }
        
        let topSong = TopSong(artist: artistTextField.text!, title: titleTextField.text!, rank: "\(pickedNumberAtIndexPath!)", mediaItem: nil, isSongPlayable: false)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.delegate?.pickedNewTopSong(topSong, forIndexPath: self.pickedNumberAtIndexPath!)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func cancelPressed() {
        dismissViewControllerAnimated(true, completion: nil)
    }

}

//MARK: UI
extension ManualSongEntryViewController {
    func setupButtons() {
        let margins = view.layoutMarginsGuide
        let fontAttribute = UIFont.chalkboardFont(withSize: 20.0)
        doneButton = UIButton()
        cancelButton = UIButton()
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(doneButton)
        view.addSubview(cancelButton)
        
        doneButton.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        doneButton.topAnchor.constraintEqualToAnchor(margins.topAnchor, constant: 200).active = true
        
        doneButton.addTarget(self, action: #selector(ManualSongEntryViewController.donePressed), forControlEvents: .TouchUpInside)
        let doneButtonAttributedString = NSAttributedString(string: "Done", attributes: [NSFontAttributeName: fontAttribute, NSForegroundColorAttributeName: UIColor().darkBlueAppDesign])
        doneButton.setAttributedTitle(doneButtonAttributedString, forState: .Normal)
        
        cancelButton.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        cancelButton.centerYAnchor.constraintEqualToAnchor(doneButton.bottomAnchor, constant: 20).active = true
        cancelButton.addTarget(self, action: #selector(ManualSongEntryViewController.cancelPressed), forControlEvents: .TouchUpInside)
        let cancelButtonAttributedString = NSAttributedString(string: "Cancel", attributes: [NSFontAttributeName: fontAttribute, NSForegroundColorAttributeName: UIColor().redAppDesign])
        cancelButton.setAttributedTitle(cancelButtonAttributedString, forState: .Normal)
        
    }
    
    func setupTextFields() {
        let colorAttribute = UIColor().darkBlueAppDesign
        let fontAttribute = UIFont.chalkboardFont(withSize: 20.0)
        
        view.addSubview(artistTextField)
        view.addSubview(titleTextField)
        
        artistTextField.translatesAutoresizingMaskIntoConstraints = false
        artistTextField.placeholder = "Artist"
        artistTextField.backgroundColor = UIColor.whiteColor()
        artistTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10.0, 0, 0)
        
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.placeholder = "Title"
        titleTextField.backgroundColor = UIColor.whiteColor()
        titleTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10.0, 0, 0)
        
        artistTextField.defaultTextAttributes = [NSFontAttributeName: fontAttribute, NSForegroundColorAttributeName: colorAttribute]
        titleTextField.defaultTextAttributes = [NSFontAttributeName: fontAttribute, NSForegroundColorAttributeName: colorAttribute]
        
        let views: [String : AnyObject] = [
            "artistView": artistTextField,
            "titleView": titleTextField,
            "doneButton": doneButton
        ]
        
        let metrics: [String : AnyObject] = [
            "artistHeight": 40,
            "titleHeight": 40
        ]
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[artistView]-20-|", options: [], metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[titleView]-20-|", options: [], metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[artistView(artistHeight)]-10-[titleView(titleHeight)]-10-[doneButton]", options: [], metrics: metrics, views: views))
        
    }
}















