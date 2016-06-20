//
//  FindFriendsViewController.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-06-15.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit
import Firebase

class FindFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    struct Friend {
        var id: String
        var username: String
    }
    
    var friends = [Friend]()
    var user: FIRUser?

    @IBOutlet weak var tableView: UITableView!
    
    let firDatabaseRef = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        getAllUsers()
    }
    
    func getAllUsers() {
        let usersRef = firDatabaseRef.child("users")
        usersRef.observeEventType(.Value, withBlock:{ (snapshot) in
            let users = snapshot.value as! [String : [String : AnyObject]]
            for user in users {
                print("\(user.1["username"]!) - id: \(user.0)")
                self.friends.append(Friend(id: user.0, username: user.1["username"]! as! String))
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("findFriendCell", forIndexPath: indexPath)
        let friend = friends[indexPath.row]
        cell.textLabel?.text = "\(friend.username)-\(friend.id)"
        
        return cell
        
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let friendSelected = friends[indexPath.row]
        
        firDatabaseRef.child("friendsGroup").child("\(user!.uid)").child("\(friendSelected.id)").setValue(["friendId": friendSelected.id])
        
//        let key = firDatabaseRef.child("friendsGroup").child("anotheruserid").child("friends").childByAutoId().key
//        let addedFriend = ["uid": friendSelected.id, "username": "\(friendSelected.username)"]
//        let childUpdates = ["/friendsGroup/anotheruserid/friends/\(key)": addedFriend]
//        firDatabaseRef.updateChildValues(childUpdates)
    }
    
    
    @IBAction func doneWasPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
















