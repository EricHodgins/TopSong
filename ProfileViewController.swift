//
//  ProfileViewController.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-06-07.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit
import MediaPlayer
import Firebase


class ProfileViewController: UIViewController, UITableViewDataSource, UINavigationControllerDelegate {
    
    let firDatabaseRef = FIRDatabase.database().reference()
    var user: FIRUser?
    
    lazy var firebaseClient: FirebaseClient = {
        return FirebaseClient()
    }()

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameTextField: UITextField!
    @IBOutlet weak var topPicksLabel: UILabel!
    
    var userTopPicks = [TopSong?](count: 3, repeatedValue: nil)
    
    let imagePicker = UIImagePickerController()
    
    let cellSongTitleAttribute = UIFont.chalkboardFont(withSize: 20.0)
    let cellSongTitleColorAttribute = UIColor().darkBlueAppDesign
    let cellArtistColorAttribute = UIColor().lightBlueAppDesign
    let cellArtistFontAttribute = UIFont.chalkboardFont(withSize: 15.0)
    let cellButtonStringAttribute = NSAttributedString(string: "Change", attributes: [NSFontAttributeName: UIFont.chalkboardFont(withSize: 15.0), NSForegroundColorAttributeName: UIColor().redAppDesign])
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadProfileName()
        downloadProfileImage()
        downloadTopSongPicks()
        
        print("logged in user: \(user?.uid)")
        
        tableView.dataSource = self
        profileNameTextField.delegate = self
        
        // Top Picks Label
        topPicksLabel.attributedText = UIDesign.lightStyleAttributedString(topPicksLabel.text!, fontSize: 25.0)
        
        //Profile Name Textfield
        let fontTextfieldAttribute = UIFont.chalkboardFont(withSize: 18.0)
        let colorTextfieldAttribute = UIColor().lightBlueAppDesign
        let mutableTextFieldPlaceholderString = NSMutableAttributedString(string: "Profile Name",
                                                               attributes: [NSFontAttributeName : fontTextfieldAttribute, NSForegroundColorAttributeName: colorTextfieldAttribute])
        profileNameTextField.attributedPlaceholder = mutableTextFieldPlaceholderString
        profileNameTextField.defaultTextAttributes = [NSFontAttributeName : fontTextfieldAttribute, NSForegroundColorAttributeName: colorTextfieldAttribute]
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
        
        cell.songTitleLabel.attributedText = UIDesign.darkStyleAttributedString(cell.songTitleLabel.text!, fontSize: 20.0)//songAttributedString
        cell.artistLabel.attributedText = UIDesign.lightStyleAttributedString(cell.artistLabel.text!, fontSize: 15.0)//artistAttributedString
        cell.changeButton.setAttributedTitle(UIDesign.highlightedAttributedString("Change", fontSize: 15.0), forState: .Normal)
        
        cell.topPickIndexPath = indexPath
        cell.delegate = self
        
        return cell
        
    }
    
}


//MARK: Textfield Delegate
extension ProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        firebaseClient.updateUsername(user!, name: profileNameTextField.text!)
        
        textField.resignFirstResponder()
        return true
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if profileNameTextField.isFirstResponder() {
            firebaseClient.updateUsername(user!, name: profileNameTextField.text!)
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
    func pickedNewTopSong(song: TopSong, forIndexPath: NSIndexPath) {
        
        // Save to Firebase database
        firebaseClient.updateTopSong(user!, indexPath: forIndexPath, song: song)
        
        //update tableview
        userTopPicks[forIndexPath.row] = song
        tableView.reloadData()
    }
}


//MARK: UIImagePicker Delegate
extension ProfileViewController: UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        dispatch_async(dispatch_get_main_queue()) {
            self.profileImageView.image = image
        }
        
        firebaseClient.uploadUserProfileImage(user!, image: image) { (success) in
            print("finished uploading image data.")
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Download Profile Image
    func downloadProfileImage() {
        firebaseClient.fetchUserImage(user!) { (success, image) in
            guard success == true else {
                return
            }
            
            self.profileImageView.image = image
        }
    }
    
    //MARK: Download Profile Name
    func downloadProfileName() {
        firebaseClient.fetchUsername(user!) { (success, username) in
            guard success == true else {
                return
            }
            self.profileNameTextField.text = username
        }
    }
    
    
    //MARK: Download Top Song Picks
    func downloadTopSongPicks() {
        
        firebaseClient.fetchUserTopSongs(user!) { (success, topSongsArray) in
            guard success == true else {
                print("error fetching top songs for user.")
                return
            }
            
            for (index, song) in topSongsArray.enumerate() {
                self.userTopPicks[index] = song
            }
            
            self.tableView.reloadData()
        }
    }
}


extension ProfileViewController {
    //TODO: Finish proper logging out
    @IBAction func logoutPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}















