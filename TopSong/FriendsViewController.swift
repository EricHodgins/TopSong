//
//  FriendsViewController.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-06-16.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit
import Firebase

class FriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UserInfoUpdating {
    
    var friends = [Friend]()
    let firebaseClient = FirebaseClient.sharedInstance
    
    var user: FIRUser?
    
    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Friends"
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont.chalkboardFont(withSize: 20.0), NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = UIDesign.lightStyleAttributedString("Pull To Refresh", fontSize: 15.0)
        refreshControl.addTarget(self, action: #selector(FriendsViewController.refreshFriendList), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        refreshFriendList()
    }

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let findFriendsNav = segue.destinationViewController as! UINavigationController
        let findFriendsVC = findFriendsNav.viewControllers.first as! FindFriendsViewController
        findFriendsVC.user = user
    }
    
    func endTableViewRefreshing() {
        refreshControl.endRefreshing()
    }
    
    func upatedFriendProfileNameAndImage(friendID: String, newName: String?) {
        for (index, friend) in friends.enumerate() {
            if friend.uid == friendID {
                if let name = newName {
                    self.friends[index].heading = name
                }
                let indexPath = NSIndexPath(forRow: index, inSection: 0)
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                break
            }
        }
    }
    
    func updateFriendSongChange(friendID: String, newTopSong: TopSong, rank: Int) {
        //Do not need this method for the moment.  Just fullfilling the protocol requirements for now
    }

    func refreshFriendList() {
        self.friends = []
        self.tableView.reloadData()
        
        firebaseClient.downloadUsersFriends(user!.uid, delegate: self) { (friend) in
            self.friends.append(friend)
            self.tableView.beginUpdates()
            let indexPath = NSIndexPath(forRow: self.friends.count - 1, inSection: 0)
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            self.tableView.endUpdates()
        }
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as! FriendTableViewCell
        
        let friend = friends[indexPath.row]
        cell.friendNameLabel.attributedText = UIDesign.darkStyleAttributedString(friend.heading!, fontSize: 20.0)
        fetchFriendsProfileImage(friend, cell: cell)
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let friend = friends[indexPath.row]
            firebaseClient.deleteFriendWithID(user!.uid, friendID: friend.uid)
            friends.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    
    
    func fetchFriendsProfileImage(friend: Friend, cell: FriendTableViewCell) {
        firebaseClient.fetchUserImage(friend.uid) { (success, image) in
            if success {
                cell.friendProfileImageVIew.image = image
                cell.friendProfileImageVIew.layer.cornerRadius = (cell.friendProfileImageView?.frame.size.height)! / 2
                cell.friendProfileImageVIew.layer.masksToBounds = true
                cell.friendProfileImageView.layer.borderWidth = 1
                cell.friendProfileImageVIew.layer.borderColor = UIColor.whiteColor().CGColor
            }
        }
    }
}






























