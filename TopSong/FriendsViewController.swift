//
//  FriendsViewController.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-06-16.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit
import Firebase

class FriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var friends = [Friend]()
    lazy var firebaseClient: FirebaseClient = {
        return FirebaseClient()
    }()
    
    var user: FIRUser?
    let firDatabaseRef = FIRDatabase.database().reference()
    
    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let findFriendsVC = segue.destinationViewController as! FindFriendsViewController
        findFriendsVC.user = user
    }
    
    func endRefreshing() {
        refreshControl.endRefreshing()
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






























