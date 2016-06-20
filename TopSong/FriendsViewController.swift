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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let findFriendsVC = segue.destinationViewController as! FindFriendsViewController
        findFriendsVC.user = user
    }

    @IBAction func refreshFriendList(sender: AnyObject) {
        let friendsRef = firDatabaseRef.child("friendsGroup").child("\(user!.uid)")
        friendsRef.observeEventType(.Value, withBlock: {(snapshot) in
            self.friends = []
            let friendsDict = snapshot.value as! [String : AnyObject]
            for friend in friendsDict {
                self.friends.append(Friend(id: "\(friend.0)", username: ""))
            }
             
            self.tableView.reloadData()
        })
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath)
        
        let friend = friends[indexPath.row]
        getFriendInfo(friend, cell: cell)
        
        return cell
    }
    
    func getFriendInfo(friend: Friend, cell: UITableViewCell) {
        let usersRef = firDatabaseRef.child("users").child(friend.id)
        usersRef.observeEventType(.Value, withBlock: {(snapshot) in
            let userDict = snapshot.value as! [String : String]
            let username = userDict["username"]!
            dispatch_async(dispatch_get_main_queue()) {
                cell.textLabel?.text = username
            }
        })
    }

}






























