//
//  TopSongsViewController.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-06-17.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit
import Firebase

class TopSongsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    lazy var firebaseClient: FirebaseClient = {
        return FirebaseClient()
    }()

    var user: FIRUser?
    var topSongs = [TopSong]()
    var friendUserIDs = [String]()
    var friendTopSongsDict = [String: [String]]()
    
    let firDatabaseRef = FIRDatabase.database().reference()
    
    @IBOutlet weak var tableView: UITableView!

    var friendsArray = [Friend]()
    var firebaseRefHandleTuples = [(FIRDatabaseReference, UInt)]()
    var downloadGroup = dispatch_group_create()
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull To Refresh", attributes: [NSFontAttributeName: UIFont.chalkboardFont(withSize: 15),NSForegroundColorAttributeName: UIColor().darkBlueAppDesign])
        refreshControl.addTarget(self, action: #selector(TopSongsViewController.downloadTopSongs), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        downloadTopSongs()
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return friendsArray.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return friendsArray[section].heading
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //Download image file with path to
        let headerView = UIView()
        headerView.backgroundColor = UIColor().lightBlueAppDesign
        
        //title
        let fontAttribute = UIFont.chalkboardFont(withSize: 22.0)
        let colorAttribute = UIColor.whiteColor()
        let attributedString = NSAttributedString(string: friendsArray[section].heading!, attributes: [NSFontAttributeName: fontAttribute, NSForegroundColorAttributeName: colorAttribute])
        let nameFrame = CGRectMake(80, 15, 200, 40)
        let nameLabel = UILabel(frame: nameFrame)
        nameLabel.attributedText = attributedString
        
        //image
        let imageFrame = CGRectMake(8, 10, 55, 55)
        let imageView = UIImageView(frame: imageFrame)
        let image: UIImage = UIImage(named: "TopSongAppIcon Copy")!
        imageView.image = image
        imageView.contentMode = .ScaleAspectFit
        
        //download profile Image
        if friendsArray[section].imagePath != nil {
            //downloadProfileImage(path, imageView: imageView)
            let userId = friendsArray[section].uid
            firebaseClient.fetchUserImage(userId, completionHandler: { (success, image) in
                if success {
                    imageView.image = image
                    imageView.layer.cornerRadius = imageView.frame.size.height / 2
                    imageView.layer.masksToBounds = true
                    imageView.contentMode = .ScaleAspectFill
                    imageView.layer.borderWidth = 1
                    imageView.layer.borderColor = UIColor.whiteColor().CGColor
                }
            })
        }
        
        
        headerView.addSubview(imageView)
        headerView.addSubview(nameLabel)
        
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsArray[section].topSongs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("topSongCell", forIndexPath: indexPath) as! TopSongTableViewCell
        
        let song = friendsArray[indexPath.section].topSongs[indexPath.row]
        cell.rank.text = song.rank
        
        let titleFontAttribute = UIFont.chalkboardFont(withSize: 20)
        let titleColorAttribute = UIColor().darkBlueAppDesign
        let titleAttributedString = NSAttributedString(string: song.title, attributes: [NSFontAttributeName: titleFontAttribute, NSForegroundColorAttributeName: titleColorAttribute])
        cell.titleLabel.attributedText = titleAttributedString
        
        let artistFontAttribute = UIFont.chalkboardFont(withSize: 15)
        let artistColorAttribute = UIColor().lightBlueAppDesign
        let artistAttributedString = NSAttributedString(string: song.artist, attributes: [NSFontAttributeName: artistFontAttribute, NSForegroundColorAttributeName: artistColorAttribute])
        cell.artistLabel.attributedText = artistAttributedString
        
        return cell
    }
    
    
    //MARK: Download Songs/Friend Info
    
    func endTableViewRefreshing() {
        print("ended table view refreshing.")
        self.refreshControl.endRefreshing()
    }
    
    func updateFriendSongChange(friendID: String, newTopSong: TopSong, rank: Int) {
        print("friend updated a new top song.")
        for (index, friend) in self.friendsArray.enumerate() {
            if friend.uid == friendID {
                friend.topSongs[rank]
                self.friendsArray[index].topSongs[rank] = newTopSong
                let indexPath = NSIndexPath(forRow: rank, inSection: index)
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                break
            }
        }
    }
    
    func downloadTopSongs() {
        
        friendsArray = []
        tableView.reloadData()
        
        firebaseClient.downloadFriendsTopSongs(user!, delegate: self) { (friend, newSongIndexPaths) in
            self.tableView.beginUpdates()
            self.friendsArray.append(friend)
            let section = NSIndexSet(index: self.friendsArray.count - 1)
            self.tableView.insertSections(section, withRowAnimation: .Automatic)
            self.tableView.insertRowsAtIndexPaths(newSongIndexPaths, withRowAnimation: .Automatic)
            self.tableView.endUpdates()
        }
        
//        for (ref, handle) in firebaseRefHandleTuples {
//            ref.removeObserverWithHandle(handle)
//        }
//        firebaseRefHandleTuples = []
//        friendsArray = []
//        self.tableView.reloadData()
//        
//        
//        let friendsRef = firDatabaseRef.child("friendsGroup").child("\(user!.uid)")
//        friendsRef.observeEventType(.Value, withBlock: {(snapshot) in
//            let friendsDict = snapshot.value as! [String : AnyObject]
//            
//            for friend in friendsDict {
//                dispatch_group_enter(self.downloadGroup)
//                self.friendUserIDs.append("\(friend.0)")
//                self.downloadFriendInfo(friend.0)
//            }
//            
//            dispatch_group_notify(self.downloadGroup, dispatch_get_main_queue()) {
//                self.delayButtonEnabled()
//            }
//            
//        })
    }
    
    //username
    func downloadFriendInfo(id: String) {
        let usersRef = firDatabaseRef.child("users").child(id)
        usersRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) in
            let usersDict = snapshot.value as! [String : String]
            let username = usersDict["username"]!
            let storedImagePath = usersDict["imageFilePath"]
            self.downloadFriendTopSongs(id, username: username, imagePath: storedImagePath)
        })
        
        let handle = usersRef.observeEventType(.ChildChanged, withBlock: {(snapshot) in
            print("username or profile image was updated.")
        })
        
        self.firebaseRefHandleTuples.append((usersRef, handle))
    }
    
    func downloadFriendTopSongs(id: String, username: String, imagePath: String?) {
        
//        let topSongRef = firDatabaseRef.child("topSongs").child(id).child("songs")
//        topSongRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) in
//            let songsArray = snapshot.value as! NSArray
//            var friend = Friend(friendName: username, friendSongs: [], friendID: id, storageImagePath: imagePath)
//            var topSongIndexes = [NSIndexPath]()
//            var indexPath: NSIndexPath
//            for (index, song) in songsArray.enumerate() {
//                let songDict = song as! [String : String]
//                let topSong = TopSong(artist: "\(songDict["songArtist"]!)", title: songDict["songTitle"]!, rank: "\(index)")
//                friend.topSongs.append(topSong)
//                indexPath = NSIndexPath(forRow: friend.topSongs.count - 1, inSection: self.friendsArray.count)
//                topSongIndexes.append(indexPath)
//            }
//            
//            self.tableView.beginUpdates()
//            self.friendsArray.append(friend)
//            let section = NSIndexSet(index: self.friendsArray.count - 1)
//            self.tableView.insertSections(section, withRowAnimation: .Automatic)
//            self.tableView.insertRowsAtIndexPaths(topSongIndexes, withRowAnimation: .Automatic)
//            self.tableView.endUpdates()
//            
//            dispatch_group_leave(self.downloadGroup)
//            
//        })
        
        
//        let handle = topSongRef.observeEventType(.ChildChanged, withBlock: {(snapshot) in
//            let songDict = snapshot.value as! [String : AnyObject]
//            let refArr = "\(snapshot.ref)".componentsSeparatedByString("/")
//            let friendID = refArr[refArr.count - 3]
//            let songRank = Int(refArr.last!)!
//            let artist = songDict["songArtist"] as! String
//            let title = songDict["songTitle"] as! String
//            //Make new song
//            let newSong = TopSong(artist: artist, title: title, rank: "\(songRank)")
//            
//            for (index, friend) in self.friendsArray.enumerate() {
//                if friend.uid == friendID {
//                    friend.topSongs[songRank]
//                    self.friendsArray[index].topSongs[songRank] = newSong
//                    let indexPath = NSIndexPath(forRow: songRank, inSection: index)
//                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
//                    break
//                }
//            }
//        })
//        
//        
//        //Need to get references and handles to remove them if a refresh is made. Otherwise multiple calls are made.
//        self.firebaseRefHandleTuples.append((topSongRef, handle))
        
    }
    
    
    //Not sure if really need this...kind of nice for refreshing UI
    func delayButtonEnabled() {
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC))
        dispatch_after(when, dispatch_get_main_queue()) {
            self.refreshControl.endRefreshing()
        }
    }
    
}


extension TopSongsViewController {
    func downloadProfileImage(imagePath: String, imageView: UIImageView) {
        let profileImage = FIRStorage.storage().referenceForURL(imagePath)//storageRef.child("\(user!.uid)\\images\\profile")
        let downloadTask = profileImage.dataWithMaxSize(1 * 1024 * 1024) { (imageData, error) in
            guard error == nil else {
                print("Error downloading profile image: \(error?.localizedDescription)")
                return
            }
            
            let image : UIImage = UIImage(data: imageData!)!
            
            dispatch_async(dispatch_get_main_queue()) {
                imageView.image = image
                imageView.layer.cornerRadius = imageView.frame.size.height / 2
                imageView.layer.masksToBounds = true
                imageView.contentMode = .ScaleAspectFill
                imageView.layer.borderWidth = 1
                imageView.layer.borderColor = UIColor.whiteColor().CGColor
            }
            
        }
        
        downloadTask.observeStatus(.Success) { (snapshot) in
            print("completed downloading profile image.")
        }
        
        downloadTask.observeStatus(.Progress) { (snapshot) in
            //TODO: Cool animation with this as well?
            //            if let progress = snapshot.progress {
            //                let percentComplete = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
            //                print(percentComplete)
            //            }
        }
    }
}





















