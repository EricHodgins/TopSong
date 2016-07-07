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
    
    let firebaseClient = FirebaseClient.sharedInstance
    
    var friends = [Friend]()
    var user: FIRUser?
    
    let searchController = UISearchController(searchResultsController: nil)

    @IBOutlet weak var tableView: UITableView!
    
    let firDatabaseRef = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.loadViewIfNeeded()
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.barTintColor = UIColor().lightBlueAppDesign
        searchController.searchBar.tintColor = UIColor.whiteColor()
        UITextField.appearanceWhenContainedInInstancesOfClasses([searchController.searchBar.dynamicType]).tintColor = UIColor.blackColor()
        
        tableView.tableHeaderView = searchController.searchBar
        tableView.delegate = self
        tableView.dataSource = self
        
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
        cell.textLabel?.attributedText = UIDesign.darkStyleAttributedString(friend.heading!, fontSize: 25.0)
        
        return cell
        
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let friendSelected = friends[indexPath.row]
        
        firDatabaseRef.child("friendsGroup").child("\(user!.uid)").child(friendSelected.uid).setValue(["friendId": friendSelected.uid])
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func doneWasPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}


extension FindFriendsViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.friends = []
        self.tableView.reloadData()
        firebaseClient.findFriendWithText(user!.uid, text: searchController.searchBar.text!) { (id, username) in
            print("found: \(username)")
            let friendFound = Friend(friendName: username, friendSongs: nil, friendID: id, storageImagePath: nil)
            self.friends.append(friendFound)
            self.tableView.reloadData()
        }
    }
}













