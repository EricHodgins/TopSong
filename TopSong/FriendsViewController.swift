//
//  FriendsViewController.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-06-16.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class FriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UserInfoUpdating {
    
    //weak var editingButton: UIBarButtonItem!
    @IBOutlet weak var editingButton: UIBarButtonItem!
    
    var friends = [Friend]()
    let firebaseClient = FirebaseClient.sharedInstance
    
    var user: FIRUser?
    var loggedInUser: User?
    
    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    var presentingAlertMessage: Bool = false
    
    //MARK: Context
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance.managedObjectContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        findUser()
        
        self.title = "Friends"
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont.chalkboardFont(withSize: 20.0), NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = UIDesign.lightStyleAttributedString("Pull To Refresh", fontSize: 15.0)
        refreshControl.addTarget(self, action: #selector(FriendsViewController.refreshFriendList), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        refreshControl.beginRefreshing()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FriendsViewController.showNetworkErrorMessage), name: networkErrorNotificationKey, object: nil)
        
        refreshFriendList()
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func findUser() {
        let fetchRequest = NSFetchRequest(entityName:"User")
        let predicate = NSPredicate(format: "userId = %@", user!.uid)
        fetchRequest.predicate = predicate
        do {
            let fetchResults = try sharedContext.executeFetchRequest(fetchRequest)
            if fetchResults.count != 0 {
                loggedInUser = fetchResults[0] as? User
            }
        } catch let error as NSError {
            print("Error occurred querying for logged in user: \(error.localizedDescription)")
        }
    }

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let findFriendsNav = segue.destinationViewController as! UINavigationController
        let findFriendsVC = findFriendsNav.viewControllers.first as! FindFriendsViewController
        let topSongsVC = tabBarController?.viewControllers![1].childViewControllers[0] as! TopSongsViewController
        findFriendsVC.user = user
        findFriendsVC.delegateFriendsViewController = self
        findFriendsVC.delegateTopSongsViewController = topSongsVC
        
        
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

    
    //MARK: Refresh friend List
    func refreshFriendList() {
        self.friends = []
        self.tableView.reloadData()
        
        firebaseClient.downloadUsersFriends(user!.uid, delegate: self) { (friend) in
            self.friends.append(friend)
            self.tableView.beginUpdates()
            let indexPath = NSIndexPath(forRow: self.friends.count - 1, inSection: 0)
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            self.tableView.endUpdates()
            self.endTableViewRefreshing()
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
        
        if let friendName = friend.heading {
            cell.friendNameLabel.attributedText = UIDesign.darkStyleAttributedString(friendName, fontSize: 20.0)
        } else {
            cell.friendNameLabel.attributedText = UIDesign.darkStyleAttributedString("Friend has not set name.", fontSize: 20.0)
        }
        
        
        fetchFriendsProfileImage(friend, cell: cell)
        
        return cell
    }
    
    //MARK: Deleting a Friend
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            //1. Update friends array
            let friend = friends[indexPath.row]
            friends.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            //2. Update Firebase Database
            firebaseClient.deleteFriendWithID(user!.uid, friendID: friend.uid)
            
            //3. Update Core Data & Remove Friends Profile Image from Documents Directory
            let fetchRequest = NSFetchRequest(entityName: "TopSongFriend")
            let predicate = NSPredicate(format: "user = %@", loggedInUser!)
            let predicate2 = NSPredicate(format: "friendId = %@", friend.uid)
            let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
            fetchRequest.predicate = compound
            
            do {
                let fetchedResult = try sharedContext.executeFetchRequest(fetchRequest)
                if fetchedResult.count == 1 {
                    let friend = fetchedResult[0] as! TopSongFriend
                    sharedContext.deleteObject(friend)
                    CoreDataStackManager.sharedInstance.saveContext()
                }
            } catch let error as NSError {
                print(error)
            }
            
            //4. Refresh TopSongsViewController
            let topSongsVC = tabBarController?.viewControllers![1].childViewControllers[0] as! TopSongsViewController
            topSongsVC.downloadTopSongs()
        }
    }
    
    
    
    func fetchFriendsProfileImage(friend: Friend, cell: FriendTableViewCell) {
        firebaseClient.fetchUserImage(friend.uid) { (success, image) in
            cell.friendProfileImageVIew.layer.cornerRadius = (cell.friendProfileImageView?.frame.size.height)! / 2
            cell.friendProfileImageVIew.layer.masksToBounds = true
            cell.friendProfileImageView.layer.borderWidth = 1
            cell.friendProfileImageVIew.layer.borderColor = UIColor.whiteColor().CGColor
            if success {
                cell.friendProfileImageVIew.image = image
            } else {
                cell.friendProfileImageVIew.backgroundColor = UIColor().lightBlueAppDesign
                cell.friendProfileImageVIew.image = UIImage(named: "ic_account_circle_white")
            }
        }
    }
    
    @IBAction func editButtonPressed(sender: AnyObject) {
        if editingButton.title == "Edit" {
            tableView.setEditing(true, animated: true)
            editingButton.title = "Done"
        } else {
            tableView.setEditing(false, animated: true)
            editingButton.title = "Edit"
        }
    }
    
}



//MARK: Error Messages

extension FriendsViewController {
    func showNetworkErrorMessage() {
        
        //make sure it's the presenting viewcontroller first
        guard tabBarController?.selectedViewController?.childViewControllers[0] == self else {
            return
        }
        
        if presentingAlertMessage == false {
            presentingAlertMessage = true
            dispatch_async(dispatch_get_main_queue()) {
                self.showMessage("Network Error", message: "Looks like there is a network problem. Check your connection.")
            }
        }
    }
    
    func showMessage(title: String, message: String?) {
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


























