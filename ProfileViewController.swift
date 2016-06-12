//
//  ProfileViewController.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-06-07.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit
import MediaPlayer


class ProfileViewController: UIViewController, UITableViewDataSource, UINavigationControllerDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameTextField: UITextField!
    @IBOutlet weak var topPicksLabel: UILabel!
    
    var userTopPicks = [MPMediaItem?](count: 3, repeatedValue: nil)
    
    let imagePicker = UIImagePickerController()
    
    let cellSongTitleAttribute = UIFont.chalkboardFont(withSize: 20.0)
    let cellSongTitleColorAttribute = UIColor().darkBlueAppDesign
    let cellArtistColorAttribute = UIColor().lightBlueAppDesign
    let cellArtistFontAttribute = UIFont.chalkboardFont(withSize: 15.0)
    let cellButtonStringAttribute = NSAttributedString(string: "Change", attributes: [NSFontAttributeName: UIFont.chalkboardFont(withSize: 15.0), NSForegroundColorAttributeName: UIColor().redAppDesign])
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        profileNameTextField.delegate = self
        
        //Setup Cell Button String Attribute
        //cellButtonStringAttribute = NSAttributedString(string: "Change", attributes: [NSFontAttributeName: ])
        
        
        // Top Picks Label
        let fontAttribute = UIFont(name: "Chalkboard SE", size: 25.0)
        let colorAttribute = UIColor().lightBlueAppDesign
        let mutableString = NSMutableAttributedString(string: topPicksLabel.text!, attributes: [NSFontAttributeName: fontAttribute!, NSForegroundColorAttributeName: colorAttribute])
        topPicksLabel.attributedText = mutableString
        
        //Profile Name Textfield
        let fontTextfieldAttribute = UIFont(name: "Chalkboard SE", size: 18.0)
        let colorTextfieldAttribute = UIColor().lightBlueAppDesign
        let mutableTextFieldPlaceholderString = NSMutableAttributedString(string: "Profile Name",
                                                               attributes: [NSFontAttributeName : fontTextfieldAttribute!, NSForegroundColorAttributeName: colorTextfieldAttribute])
        profileNameTextField.attributedPlaceholder = mutableTextFieldPlaceholderString
        profileNameTextField.defaultTextAttributes = [NSFontAttributeName : fontTextfieldAttribute!, NSForegroundColorAttributeName: colorTextfieldAttribute]
        profileNameTextField.textAlignment = .Center
        
        
        // Picking Profile Image
        
        profileImageView.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.3)
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height / 2
        profileImageView.layer.masksToBounds = true
        
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.borderColor = UIColor().lightBlueAppDesign.CGColor
        
        //Single Tap to Change Picture
        let newPictureGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.pickNewPictureForProfile))
        profileImageView.userInteractionEnabled = true
        profileImageView.addGestureRecognizer(newPictureGestureRecognizer)
        
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.allowsEditing = false
        
    }

    
    func pickNewPictureForProfile() {
        print("picking new picture..")
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("profileCell", forIndexPath: indexPath) as! TopPickTableViewCell
        
        let separator = UIView(frame:CGRect(x: 10, y: cell.contentView.frame.size.height - 1, width: view.frame.size.width - 40, height: 1.0))
        separator.backgroundColor = UIColor().lightBlueAppDesign
        cell.contentView.addSubview(separator)
        
        if let song = userTopPicks[indexPath.row] {
            cell.songTitleLabel.text = song.title
            cell.artistLabel.text = song.artist
        } else {
            cell.songTitleLabel.text = "Pick A New Top Song"
            cell.artistLabel.text = ""
        }
        
        let songAttributedString = NSMutableAttributedString(string: cell.songTitleLabel.text!, attributes: [NSFontAttributeName: cellSongTitleAttribute, NSForegroundColorAttributeName: cellSongTitleColorAttribute])
        let artistAttributedString = NSMutableAttributedString(string: cell.artistLabel.text!, attributes: [NSFontAttributeName: cellArtistFontAttribute, NSForegroundColorAttributeName: cellArtistColorAttribute])
        cell.songTitleLabel.attributedText = songAttributedString
        cell.artistLabel.attributedText = artistAttributedString
        cell.changeButton.setAttributedTitle(cellButtonStringAttribute, forState: .Normal)
        
        cell.topPickIndexPath = indexPath
        cell.delegate = self
        
        return cell
        
    }
    
}


//MARK: Textfield Delegate
extension ProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if profileNameTextField.isFirstResponder() {
            profileNameTextField.resignFirstResponder()
        }
    }
}


//MARK: SongChanging Protocol
extension ProfileViewController: SongChanging {
    func changingNewTopSongAt(indexPath: NSIndexPath) {
        let songPickerNavVC = storyboard?.instantiateViewControllerWithIdentifier("SongPicker") as! UINavigationController
        let songPickerVC = songPickerNavVC.viewControllers[0] as! SongPickerViewController
        songPickerVC.pickedNumberAtIndexPath = indexPath
        songPickerVC.delegate = self
        songPickerNavVC.modalPresentationStyle = .OverCurrentContext
        tabBarController?.presentViewController(songPickerNavVC, animated: true, completion: nil)
    }
}

//MARK: SongPicking Protocol
extension ProfileViewController: SongPicking {
    func pickedNewTopSong(song: MPMediaItem, forIndexPath: NSIndexPath) {
        userTopPicks[forIndexPath.row] = song
        tableView.reloadData()
    }
}


//MARK: UIImagePicker Delegate
extension ProfileViewController: UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        profileImageView.image = image
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}


















