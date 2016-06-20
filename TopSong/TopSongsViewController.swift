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
    
    struct TopSong {
        var artist: String
        var title: String
        var rank: String
    }
    

    
    @IBOutlet weak var retrieveSongsButton: UIBarButtonItem!
    var user: FIRUser?
    var topSongs = [TopSong]()
    var friendUserIDs = [String]()
    var friendTopSongsDict = [String: [String]]()
    
    let firDatabaseRef = FIRDatabase.database().reference()
    
    @IBOutlet weak var tableView: UITableView!
    
    struct Friend {
        var heading: String
        var topSongs: [TopSong]
        var uid: String
        
        init(friendName: String, friendSongs: [TopSong], friendID: String) {
            heading = friendName
            topSongs = friendSongs
            uid = friendID
        }
    }
    var friendsArray = [Friend]()
    var firebaseRefHandleTuples = [(FIRDatabaseReference, UInt)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return friendsArray.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return friendsArray[section].heading
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor().lightBlueAppDesign
        
        //title
        let nameFrame = CGRectMake(10, 0, 200, 40)
        let nameLabel = UILabel(frame: nameFrame)
        nameLabel.text = friendsArray[section].heading
        
        //image
        let imageFrame = CGRectMake(self.view.frame.size.width - 70, 0, 45, 45)
        let imageView = UIImageView(frame: imageFrame)
        let image: UIImage = UIImage(named: "TopSongAppIcon Copy")!
        imageView.image = image
        imageView.contentMode = .ScaleAspectFit
        
        headerView.addSubview(imageView)
        headerView.addSubview(nameLabel)
        
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsArray[section].topSongs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("topSongCell", forIndexPath: indexPath) as! TopSongTableViewCell
        
        let song = friendsArray[indexPath.section].topSongs[indexPath.row]
        cell.artistLabel.text = song.artist
        cell.titleLabel.text = song.title
        cell.rank.text = song.rank
        
        return cell
    }
    
    @IBAction func downloadTopSongs(sender: AnyObject) {
        print("Refreshed pressed.")
        retrieveSongsButton.enabled = false
        for (ref, handle) in firebaseRefHandleTuples {
            ref.removeObserverWithHandle(handle)
        }
        print(firebaseRefHandleTuples)
        firebaseRefHandleTuples = []
        friendsArray = []
        let friendsRef = firDatabaseRef.child("friendsGroup").child("\(user!.uid)")
        friendsRef.observeEventType(.Value, withBlock: {(snapshot) in
            let friendsDict = snapshot.value as! [String : AnyObject]
            for friend in friendsDict {
                self.friendUserIDs.append("\(friend.0)")
                self.downloadFriendInfo(friend.0)
            }
            
            self.delayButtonEnabled()
        })
    }
    
    //username
    func downloadFriendInfo(id: String) {
        let usersRef = firDatabaseRef.child("users").child(id)
        usersRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) in
            let usersDict = snapshot.value as! [String : String]
            let username = usersDict["username"]!
            self.downloadFriendTopSongs(id, username: username)
        })
        
        let handle = usersRef.observeEventType(.ChildChanged, withBlock: {(snapshot) in
            print("username updated.")
        })
        
        self.firebaseRefHandleTuples.append((usersRef, handle))
    }
    
    func downloadFriendTopSongs(id: String, username: String) {
        let topSongRef = firDatabaseRef.child("topSongs").child(id).child("songs")
        topSongRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) in
            let songsArray = snapshot.value as! NSArray
            var friend = Friend(friendName: username, friendSongs: [], friendID: id)
            for (index, song) in songsArray.enumerate() {
                let songDict = song as! [String : String]
                let topSong = TopSong(artist: "\(songDict["songArtist"]!)", title: songDict["songTitle"]!, rank: "\(index)")
                friend.topSongs.append(topSong)
                print("called again...")
            }
            
            self.friendsArray.append(friend)
            self.tableView.reloadData()
        })
        
        
        let handle = topSongRef.observeEventType(.ChildChanged, withBlock: {(snapshot) in
            print("song update.")
            print(snapshot.ref)
            let songDict = snapshot.value as! [String : AnyObject]
            let refArr = "\(snapshot.ref)".componentsSeparatedByString("/")
            let friendID = refArr[refArr.count - 3]
            let songRank = Int(refArr.last!)!
            let artist = songDict["songArtist"] as! String
            let title = songDict["songTitle"] as! String
            //Make new song
            let newSong = TopSong(artist: artist, title: title, rank: "\(songRank)")
            
            for (index, friend) in self.friendsArray.enumerate() {
                if friend.uid == friendID {
                    friend.topSongs[songRank]
                    self.friendsArray[index].topSongs[songRank] = newSong
                    break
                }
            }
            
            self.tableView.reloadData()
        })
        
        
        //Need to get references and handles to remove them if refreshed is pressed. Otherwise multiple calls are made.
        self.firebaseRefHandleTuples.append((topSongRef, handle))
        
    }
    
    
    //Not sure if need this...was put in to stop multiple requests made really fast a part.
    func delayButtonEnabled() {
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * NSEC_PER_SEC))
        dispatch_after(when, dispatch_get_main_queue()) {
            self.retrieveSongsButton.enabled = true
        }
    }
    
}





















