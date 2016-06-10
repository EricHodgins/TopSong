//
//  ProfileViewController.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-06-07.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit
import MediaPlayer

protocol SongChanging: class {
    func changingNewTopSongAt(indexPath: NSIndexPath)
}

protocol SongPicking: class {
    func pickedNewTopSong(song: MPMediaItem, forIndexPath: NSIndexPath)
}


class ProfileViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameTextField: UITextField!
    
    let nameTextFieldBottomLine = UIView()
    var userTopPicks = [MPMediaItem?](count: 3, repeatedValue: nil)
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        profileNameTextField.delegate = self
        
        profileImageView.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.3)
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height / 2
        profileImageView.layer.masksToBounds = true
        
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.borderColor = UIColor(red: 145/255, green: 187/255, blue: 212/255, alpha: 1.0).CGColor
        
        view.addSubview(nameTextFieldBottomLine)
        nameTextFieldBottomLine.backgroundColor = UIColor(red: 145/255, green: 187/255, blue: 212/255, alpha: 1.0)

    }
    
    
    override func viewDidLayoutSubviews() {
        nameTextFieldBottomLine.translatesAutoresizingMaskIntoConstraints = false
        
        nameTextFieldBottomLine.topAnchor.constraintEqualToAnchor(profileNameTextField.bottomAnchor).active = true
        nameTextFieldBottomLine.centerXAnchor.constraintEqualToAnchor(profileNameTextField.centerXAnchor).active = true
        nameTextFieldBottomLine.widthAnchor.constraintEqualToConstant(profileNameTextField.frame.size.width).active = true
        nameTextFieldBottomLine.heightAnchor.constraintEqualToConstant(1.0).active = true
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
        separator.backgroundColor = UIColor(red: 145/255, green: 187/255, blue: 212/255, alpha: 1.0)
        cell.contentView.addSubview(separator)
        
        if let song = userTopPicks[indexPath.row] {
            cell.songTitleLabel.text = song.title
            cell.artistLabel.text = song.artist
        } else {
            cell.songTitleLabel.text = "Pick A New Top Song"
            cell.artistLabel.text = ""
        }
        
        cell.topPickIndexPath = indexPath
        cell.delegate = self
        
        return cell
        
    }
    
}


extension ProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print("textfield")
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if profileNameTextField.isFirstResponder() {
            profileNameTextField.resignFirstResponder()
        }
    }
}



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


extension ProfileViewController: SongPicking {
    func pickedNewTopSong(song: MPMediaItem, forIndexPath: NSIndexPath) {
        userTopPicks[forIndexPath.row] = song
        tableView.reloadData()
    }
}





















