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
    
    struct Friend {
        var id: String
        var username: String
    }
    
    var friends = [Friend]()
    
    var user: FIRUser?
    let firDatabaseRef = FIRDatabase.database().reference()
    
    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull To Refresh", attributes: [NSFontAttributeName: UIFont.chalkboardFont(withSize: 15),NSForegroundColorAttributeName: UIColor().darkBlueAppDesign])
        refreshControl.addTarget(self, action: #selector(FriendsViewController.refreshFriendList), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        refreshFriendList()
    }

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let findFriendsVC = segue.destinationViewController as! FindFriendsViewController
        findFriendsVC.user = user
    }

    func refreshFriendList() {
        let friendsRef = firDatabaseRef.child("friendsGroup").child("\(user!.uid)")
        friendsRef.observeEventType(.Value, withBlock: {(snapshot) in
            self.friends = []
            let friendsDict = snapshot.value as! [String : AnyObject]
            for friend in friendsDict {
                self.friends.append(Friend(id: "\(friend.0)", username: ""))
            }
             
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        })
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
        getFriendInfo(friend, cell: cell)
        
        return cell
    }
    
    func getFriendInfo(friend: Friend, cell: FriendTableViewCell) {
        let usersRef = firDatabaseRef.child("users").child(friend.id)
        usersRef.observeEventType(.Value, withBlock: {(snapshot) in
            let userDict = snapshot.value as! [String : String]
            let username = userDict["username"]!
            dispatch_async(dispatch_get_main_queue()) {
                let fontAttribute = UIFont.chalkboardFont(withSize: 20.0)
                let colorAttribute = UIColor().darkBlueAppDesign
                let attributedString = NSAttributedString(string: username, attributes: [NSFontAttributeName: fontAttribute, NSForegroundColorAttributeName: colorAttribute])
                cell.friendNameLabel?.attributedText = attributedString
            }
        })
    }

}






























