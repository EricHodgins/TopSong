//
//  ProfileViewController.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-06-07.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit
import CoreData
import MediaPlayer
import Firebase


class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, SoundBarAnimatable {
    
    let firDatabaseRef = FIRDatabase.database().reference()
    var user: FIRUser? // Firebase
    var loggedInUser: User? // Core Data
    
    let firebaseClient = FirebaseClient.sharedInstance
    var animatingCellIndex: NSIndexPath?
    var tempAnimatingCellIndex: NSIndexPath?

    @IBOutlet weak var scrollView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameTextField: UITextField!
    @IBOutlet weak var topPicksLabel: UILabel!
    
    var userTopPicks = [TopSong?](count: 3, repeatedValue: nil)
    var currentAnimatingCell: TopPickTableViewCell?
    
    let imagePicker = UIImagePickerController()
    
    let cellSongTitleAttribute = UIFont.chalkboardFont(withSize: 20.0)
    let cellSongTitleColorAttribute = UIColor().darkBlueAppDesign
    let cellArtistColorAttribute = UIColor().lightBlueAppDesign
    let cellArtistFontAttribute = UIFont.chalkboardFont(withSize: 15.0)
    
    @IBOutlet weak var tableView: UITableView!
    
    var presentingAlertMessage: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MusicManager.sharedInstance.profileViewController = self
    
        setupBackgroundGradient()
        downloadProfileName()
        downloadProfileImage()
        downloadTopSongPicks()
        
        print("logged in user: \(user?.uid)")
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont.chalkboardFont(withSize: 20.0), NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        tableView.dataSource = self
        tableView.delegate = self
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
        
        //Check if user is saved already on the device.  If not save the user's id
        findUser()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProfileViewController.showNetworkErrorMessage), name: networkErrorNotificationKey, object: nil)
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Restart the animations.  If this is animating and switch to another viewcontroller the CPU jumps very high.
        animatingCellIndex = tempAnimatingCellIndex
        tableView.reloadData()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Stop animations but save the indexPath if needed.  If this is animating and switch to another viewcontroller the CPU jumps very high.
        tempAnimatingCellIndex = animatingCellIndex
        animatingCellIndex = nil
    }
    
    //MARK: Find User
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance.managedObjectContext
    }()
    
    func findUser() {
        let fetchRequest = NSFetchRequest(entityName:"User")
        let predicate = NSPredicate(format: "userId = %@", user!.uid)
        fetchRequest.predicate = predicate
        do {
            let fetchResults = try sharedContext.executeFetchRequest(fetchRequest)
            if fetchResults.count == 0 {
                //Make a Logged In User Entity
                let _ = User(userId: user!.uid, context: sharedContext)
                
                //Save The User
                CoreDataStackManager.sharedInstance.saveContext()
                
            } else {
                loggedInUser = fetchResults[0] as? User
                print("found user: \(loggedInUser)")
            }
        } catch let error as NSError {
            print("Error occurred querying for logged in user: \(error.localizedDescription)")
        }
    }
    
    
    func pickNewPictureForProfile() {
        presentViewController(imagePicker, animated: true, completion: nil)
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
            
            //configure Soundbars
            configureSoundBarAnimation(cell, indexPath: indexPath)
            
        } else {
            cell.songTitleLabel.text = "Pick A New Top Song"
            cell.artistLabel.text = ""
        }
        
        cell.songTitleLabel.attributedText = UIDesign.darkStyleAttributedString(cell.songTitleLabel.text!, fontSize: 20.0)//songAttributedString
        cell.artistLabel.attributedText = UIDesign.lightStyleAttributedString(cell.artistLabel.text!, fontSize: 15.0)//artistAttributedString
        cell.changeButton.setAttributedTitle(UIDesign.highlightedAttributedString("Change", fontSize: 15.0), forState: .Normal)
        
        cell.topPickIndexPath = indexPath
        cell.delegate = self
        cell.backgroundColor = UIColor.clearColor()
        
        return cell
        
    }
    
    func configureSoundBarAnimation(cell: TopPickTableViewCell, indexPath: NSIndexPath) {
        if animatingCellIndex != nil {
            if animatingCellIndex! == indexPath {
                cell.artistTitleLeadingMarginConstraint.constant = -45
                cell.songTitleLeadingMarginConstraint.constant = -45
                cell.leftBarView.alpha = 1.0
                cell.middleBarView.alpha = 1.0
                cell.rightBarView.alpha = 1.0
                
                startSoundBarAnimation(cell)
            }
        }
    }
    
    //MARK: Error Messages
    func showNetworkErrorMessage() {
        
        //make sure it's the presenting viewcontroller first
        guard tabBarController?.selectedViewController?.childViewControllers[0] == self else {
            return
        }
        
        if presentingAlertMessage == false {
            dispatch_async(dispatch_get_main_queue()) {
                self.activityIndicator.stopAnimating()
                self.showMessage("Network Error", message: "Looks like there is a network problem. Check your connection.")
            }
        }
    }
    
    func showMessage(title: String, message: String?) {
        presentingAlertMessage = true
        let errorMessage: String
        if message != nil {
            errorMessage = message!
        } else {
            errorMessage = ""
        }
        
        let alertController = UIAlertController(title: title, message: errorMessage, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default) { (action) in
            self.presentingAlertMessage = false
        }
        
        alertController.addAction(action)
        
        self.presentViewController(alertController, animated: true, completion: nil)
        print(errorMessage)
    }

}


//MARK: Textfield Delegate
extension ProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField == profileNameTextField {
            firebaseClient.updateUsername(user!, name: profileNameTextField.text!)
        }
        
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


//MARK: SongChanging Protocol - This brings up the Modal presentation to pick a song from the music library from the Music App
extension ProfileViewController: SongChanging {
    func changingNewTopSongAt(indexPath: NSIndexPath) {
        
        let alertController = UIAlertController(title: "Choose an Option to Pick a Song", message: nil, preferredStyle: .Alert)
        let manualAction = UIAlertAction(title: "Manual Entry", style: .Default) { (action) in
            print("choose to enter manually.")
            let manualVC = self.storyboard?.instantiateViewControllerWithIdentifier("manualEntry") as! ManualSongEntryViewController
            manualVC.delegate = self
            manualVC.pickedNumberAtIndexPath = indexPath
            manualVC.modalPresentationStyle = .OverCurrentContext
            self.tabBarController?.presentViewController(manualVC, animated: true, completion: nil)
        }
        
        let pickFromDeviceMedia = UIAlertAction(title: "Music Library", style: .Default) { (action) in
            let songPickerNavVC = self.storyboard?.instantiateViewControllerWithIdentifier("SongPicker") as! UINavigationController
            let songPickerVC = songPickerNavVC.viewControllers[0] as! SongPickerViewController
            songPickerVC.pickedNumberAtIndexPath = indexPath
            songPickerVC.delegate = self
            songPickerNavVC.modalPresentationStyle = .OverCurrentContext
            self.tabBarController?.presentViewController(songPickerNavVC, animated: true, completion: nil)
        }
        
        alertController.addAction(pickFromDeviceMedia)
        alertController.addAction(manualAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
}



//MARK: SongPicking Protocol - The user finisehd picking a song
extension ProfileViewController: SongPicking {
    func pickedNewTopSong(song: TopSong, forIndexPath: NSIndexPath) {
        
        //Stop animting sound bars if necessary
        if animatingCellIndex != nil {
            if let mediaItem = song.mediaItem {
                if mediaItem != MusicManager.sharedInstance.currentlyPlayingMediaItem! {
                    animatingCellIndex = nil
                }
            }
        }
        
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
        firebaseClient.fetchUserImage(user!.uid) { (success, image) in
            guard success == true else {
                return
            }
            
            self.profileImageView.image = image
        }
    }
    
    //MARK: Download Profile Name
    func downloadProfileName() {
        firebaseClient.fetchProfileName(user!) { (success, errorMessage, username) in
            guard success == true else {
                return
            }
            self.profileNameTextField.text = username
        }
    }
    
    
    //MARK: Download Top Song Picks
    func downloadTopSongPicks() {
        activityIndicator.startAnimating()
        view.alpha = 0.6
        firebaseClient.fetchUserTopSongs(user!) { (success, errorMessage, topSongsArray) in
            guard success == true else {
                print("error fetching top songs for user.")
                self.activityIndicator.stopAnimating()
                self.view.alpha = 1.0
                return
            }
            
            for (index, song) in topSongsArray.enumerate() {
                
                guard song != nil else {
                    continue
                }
                
                self.userTopPicks[index] = song
            }
            
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
            self.view.alpha = 1.0
        }
    }
}


extension ProfileViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "settings" {
            let settingsViewController = segue.destinationViewController as! SettingsViewController
            settingsViewController.user = user
        }
    }
}














