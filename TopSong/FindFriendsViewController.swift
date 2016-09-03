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
    var delegateFriendsViewController: FriendsViewController?
    var delegateTopSongsViewController: TopSongsViewController?
    
    var friends = [Friend]()
    var user: FIRUser?
    
    let searchController = UISearchController(searchResultsController: nil)
    var activityView: UIActivityIndicatorView!
    var presentingAlertMessage: Bool = false

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    let firDatabaseRef = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.setTitleTextAttributes([NSFontAttributeName: UIFont.chalkboardFont(withSize: 20.0)], forState: .Normal)
        
        searchController.searchResultsUpdater = self
        searchController.loadViewIfNeeded()
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.barTintColor = UIColor().lightBlueAppDesign //background color for search bar
        searchController.searchBar.tintColor = UIColor.whiteColor()
        UITextField.appearanceWhenContainedInInstancesOfClasses([searchController.searchBar.dynamicType]).tintColor = UIColor().darkBlueAppDesign //Cursor color
        UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([searchController.searchBar.dynamicType]).setTitleTextAttributes([NSFontAttributeName : UIFont.chalkboardFont(withSize: 20.0)], forState: .Normal) //Cancel Font

        
        let tf = searchController.searchBar.valueForKey("searchField") as? UITextField
        tf?.defaultTextAttributes = [NSFontAttributeName: UIFont.chalkboardFont(withSize: 20.0), NSForegroundColorAttributeName: UIColor().darkBlueAppDesign] //Font & Color type for search textfield
        let tfPlaceholder = tf!.valueForKey("placeholderLabel") as? UILabel
        tfPlaceholder?.textColor = UIColor().lightBlueAppDesign // placeholder attribute Font
        
        tableView.tableHeaderView = searchController.searchBar
        tableView.delegate = self
        tableView.dataSource = self
        
        activityView = UIActivityIndicatorView()
        activityView.activityIndicatorViewStyle = .WhiteLarge
        activityView.color = UIColor().darkBlueAppDesign
        activityView.center.x = view.center.x
        activityView.center.y = view.center.y - 100
        activityView.hidesWhenStopped = true
        view.addSubview(activityView)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FindFriendsViewController.showNetworkErrorMessage), name: networkErrorNotificationKey, object: nil)
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
        delegateFriendsViewController?.refreshFriendList()
        delegateTopSongsViewController?.downloadTopSongs()
        showMessage("Friend Added!", message: nil)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func doneWasPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}


extension FindFriendsViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        activityView.startAnimating()
        self.friends = []
        self.tableView.reloadData()
        firebaseClient.findFriendWithText(user!.uid, text: searchController.searchBar.text!, delegate: self) { (id, username) in
            
            if id == "" && username == "" {
                print("did not find username")
            } else {
                print("found: \(username)")
                let friendFound = Friend(friendName: username, friendSongs: nil, friendID: id, storageImagePath: nil, imageUpdate: nil)
                self.friends.append(friendFound)
                self.tableView.reloadData()
            }
            
            //setup a slight delay for visual queue
            let when = dispatch_time(DISPATCH_TIME_NOW, Int64(500 * Double(NSEC_PER_MSEC)))
            dispatch_after(when, dispatch_get_main_queue()) {
                self.activityView.stopAnimating()
            }
        }
    }
}


extension FindFriendsViewController {
    func showNetworkErrorMessage() {
        
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










