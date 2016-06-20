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
        
        downloadProfileName()
        downloadProfileImage()
        downloadTopSongPicks()
        
        print("logged in user: \(user?.uid)")
        
        tableView.dataSource = self
        profileNameTextField.delegate = self
        
        // Top Picks Label
        let fontAttribute = UIFont.chalkboardFont(withSize: 25.0)
        let colorAttribute = UIColor().lightBlueAppDesign
        let mutableString = NSMutableAttributedString(string: topPicksLabel.text!, attributes: [NSFontAttributeName: fontAttribute, NSForegroundColorAttributeName: colorAttribute])
        topPicksLabel.attributedText = mutableString
        
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
        
        firDatabaseRef.child("users").child(user!.uid).setValue(["username": textField.text!])
        firDatabaseRef.child("friendsGroup").child(user!.uid)
        
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
        
        // Save to Firebase database
        firDatabaseRef.child("topSongs").child(user!.uid).child("songs").child("\(forIndexPath.row)").setValue(["songTitle": song.title!, "songArtist": song.artist!])
        
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
        
        let imageData : NSData? = UIImageJPEGRepresentation(image, 0.1)
        
        // Root reference
        let storageRef = FIRStorage.storage().referenceForURL("gs://project-6981864531344520331.appspot.com")
        
        //Points to references
        let imagesRef = storageRef.child("\(user!.uid)\\images\\profile")
        
        //Upload image data to Firebase storage bucket
        let uploadTask = imagesRef.putData(imageData!, metadata: nil) { metadata, error in
            guard error == nil else {
                print("Error uploading profile image.\(error?.localizedDescription)")
                return
            }
        }
        
        uploadTask.observeStatus(.Success) { (snapshot) in
            print("success uploading profile image data.")
        }
        
        uploadTask.observeStatus(.Progress) { (snapshot) in
            //TODO: Maybe do some cool animation with this feature while downloading.
//            if let progress = snapshot.progress {
//                let percentComplete = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
//                print(percentComplete)
//            }
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Download Profile Image
    func downloadProfileImage() {
        let storageRef = FIRStorage.storage().referenceForURL("gs://project-6981864531344520331.appspot.com")
        let profileImage = storageRef.child("\(user!.uid)\\images\\profile")
        
        let downloadTask = profileImage.dataWithMaxSize(1 * 1024 * 1024) { (imageData, error) in
            guard error == nil else {
                print("Error downloading profile image: \(error?.localizedDescription)")
                return
            }
            
            let image : UIImage = UIImage(data: imageData!)!
            
            dispatch_async(dispatch_get_main_queue()) {
                self.profileImageView.image = image
            }
            
        }
        
        downloadTask.observeStatus(.Success) { (snapshot) in
            print("completed downloading profile image.")
        }
        
        downloadTask.observeStatus(.Progress) { (snapshot) in
            //TODO: Cool animation with this as well?
//            if let progress = snapshot.progress {
//                let percentComplete = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
//                print(percentComplete)
//            }
        }
    }
    
    //MARK: Download Profile Name
    func downloadProfileName() {
        let nameRef = firDatabaseRef.child("users").child("\(user!.uid)")
        nameRef.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            print(snapshot.value)
            let username = snapshot.value as! [String : String]
            print(username)
            dispatch_async(dispatch_get_main_queue()) {
                self.profileNameTextField.text = username["username"]
            }
        })
    }
    
    
    //MARK: Download Top Song Picks
    func downloadTopSongPicks() {
        let topSongsRef = firDatabaseRef.child("topSongs").child("\(user!.uid)").child("songs")
        topSongsRef.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            let songArray = snapshot.value as! NSArray
            for (index, song) in songArray.enumerate() {
                let songDict = song as! [String : String]
                let artistPredicate = MPMediaPropertyPredicate(value: songDict["songArtist"]!, forProperty: MPMediaItemPropertyArtist)
                let titlePredicate = MPMediaPropertyPredicate(value: songDict["songTitle"], forProperty: MPMediaItemPropertyTitle)
                
                //TODO: Figure out what happens when the query can't find the song.
                let query: MPMediaQuery = MPMediaQuery.songsQuery()
                query.addFilterPredicate(artistPredicate)
                query.addFilterPredicate(titlePredicate)
                let songMediaItem = query.items![0]
                self.userTopPicks[index] = songMediaItem
            }
            
            self.tableView.reloadData()
        })
        
    }
}


















