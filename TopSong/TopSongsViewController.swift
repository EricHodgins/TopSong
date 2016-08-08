//
//  TopSongsViewController.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-06-17.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import MediaPlayer

class TopSongsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UserInfoUpdating {
    
    let firebaseClient = FirebaseClient.sharedInstance

    var user: FIRUser?
    var loggedInUser: User?
    
    @IBOutlet weak var tableView: UITableView!

    var friendsArray = [Friend]()
    var refreshControl: UIRefreshControl!
    
    var currentAnimatingCell: TopSongTableViewCell?
    
    lazy var musicPlayer: MPMusicPlayerController = {
        return MPMusicPlayerController.systemMusicPlayer()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Top Songs"
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont.chalkboardFont(withSize: 20.0), NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = UIDesign.lightStyleAttributedString("Pull To Refresh", fontSize: 15.0)
        refreshControl.addTarget(self, action: #selector(TopSongsViewController.downloadTopSongs), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        refreshControl.beginRefreshing()
        
        findUser()
        downloadTopSongs()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if currentAnimatingCell != nil {
           activateSoundBars(currentAnimatingCell!)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        currentAnimatingCell?.leftBarView.transform = CGAffineTransformIdentity
        currentAnimatingCell?.middleBarView.transform = CGAffineTransformIdentity
        currentAnimatingCell?.rightBarView.transform = CGAffineTransformIdentity
    }
    
    //MARK: Context
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance.managedObjectContext
    }()
    
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
    
    
    //MARK: Tableview Delegate/DataSource
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
        
        //title (user name)
        let nameFrame = CGRectMake(80, 3, 200, 40)
        let nameLabel = UILabel(frame: nameFrame)
        nameLabel.attributedText = UIDesign.customColorStyleAttributedString(friendsArray[section].heading!, fontSize: 22.0, color: UIColor.whiteColor())
        
        //image
        let imageFrame = CGRectMake(8, -6, 60, 60)
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
        return 50
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsArray[section].topSongs!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("topSongCell", forIndexPath: indexPath) as! TopSongTableViewCell
        
        let song = friendsArray[indexPath.section].topSongs![indexPath.row]
        if song.isSongPlayable {
            cell.iphoneNotPlayableImageView.alpha = 0
            cell.artistLabel.alpha = 1.0
            cell.titleLabel.alpha = 1.0
            if musicPlayer.nowPlayingItem == song.mediaItem! {
                activateSoundBars(cell)
            }
        } else {
            cell.titleLabel.alpha = 0.4
            cell.artistLabel.alpha = 0.4
            cell.iphoneNotPlayableImageView.alpha = 1.0
        }
        
        cell.titleLabel.attributedText = UIDesign.darkStyleAttributedString(song.title, fontSize: 20.0)
        cell.artistLabel.attributedText = UIDesign.lightStyleAttributedString(song.artist, fontSize: 15.0)
        cell.delegate = self
        cell.songIndexPath = indexPath
        
        return cell
    }

    //MARK: Download Songs/Friend Info
    
    func endTableViewRefreshing() {
        self.refreshControl.endRefreshing()
    }
    
    func upatedFriendProfileNameAndImage(friendID: String, newName: String?) {
        
        for (index, friend) in friendsArray.enumerate() {
            if friend.uid == friendID {
                if let name = newName {
                    self.friendsArray[index].heading = name
                }
                let section = NSIndexSet(index: index)
                self.tableView.reloadSections(section, withRowAnimation: .Automatic)
            }
        }

    }
    
    func updateFriendSongChange(friendID: String, newTopSong: TopSong, rank: Int) {
        print("friend updated a new top song.")
        for (index, friend) in self.friendsArray.enumerate() {
            if friend.uid == friendID {
                friend.topSongs![rank]
                self.friendsArray[index].topSongs![rank] = newTopSong
                let indexPath = NSIndexPath(forRow: rank, inSection: index)
                self.tableView.beginUpdates()
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                self.tableView.endUpdates()
                break
            }
        }
    }
    
    func downloadTopSongs() {
        if currentAnimatingCell != nil {
            musicPlayer.stop()
            stopSoundBarAnimation(currentAnimatingCell!)
        }
        
        friendsArray = []
        tableView.reloadData()
        
        firebaseClient.downloadFriendsTopSongs(user!, delegate: self) { (friend, newSongIndexPaths) in
            self.tableView.beginUpdates()
            self.friendsArray.append(friend)
            let section = NSIndexSet(index: self.friendsArray.count - 1)
            self.tableView.insertSections(section, withRowAnimation: .Automatic)
            var indexPaths = [NSIndexPath]()
            if friend.topSongs != nil {
                for (index, _) in friend.topSongs!.enumerate() {
                    let ip = NSIndexPath(forRow: index, inSection: self.friendsArray.count - 1)
                    indexPaths.append(ip)
                }
            }
            self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
            self.tableView.endUpdates()
            
            self.updateFriend(friend, inSection: section)
        }
    }
    
    
    //MARK: Update Friend for Core Data
    //TODO: Make this a generic function. Probably will reuse this.
    func updateFriend(friend: Friend, inSection section: NSIndexSet) {
        let fetchRequest = NSFetchRequest(entityName: "TopSongFriend")
        let predicate = NSPredicate(format: "user = %@", loggedInUser!)
        let predicate2 = NSPredicate(format: "friendId = %@", friend.uid)
        let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        fetchRequest.predicate = compound

        do {
            let fetchedResults = try sharedContext.executeFetchRequest(fetchRequest)
            if fetchedResults.count == 0 {
                let topSongFriend = TopSongFriend(friendId: friend.uid ,imageFilePath: friend.imagePath!, lastImageUpdate: friend.lastImageUpdate!, context: sharedContext)
                topSongFriend.user = loggedInUser!
                
                //Save
                CoreDataStackManager.sharedInstance.saveContext()
            } else {
                print("User already saved songs")
                let topSongFriend = fetchedResults[0] as! TopSongFriend
                checkLastImageUpate(topSongFriend, inSection: section)
            }
            
        } catch let error as NSError {
            print("Error occurred querying for logged in user: \(error.localizedDescription)")
        }
    }
    
    func checkLastImageUpate(topSongFriend: TopSongFriend, inSection section: NSIndexSet) {
        for friend in friendsArray {
            if friend.uid == topSongFriend.friendId {
                //check the last image update
                if friend.lastImageUpdate == topSongFriend.lastImageUpdate {
                    print("Images up to date")
                } else {
                    print("Need to update images.  Dates don't match.")
                    //1. Remove Image from Documents Directory
                    //2. Remove Image from Cache
                    FirebaseClient.Caches.imageCache.removeImage(forPath: topSongFriend.friendId)
                    
                    //3. Download friends new Image
                    FirebaseClient.sharedInstance.fetchUserImage(topSongFriend.friendId, completionHandler: { (success, image) in
                        if success {
                            //4. Update the Section Header
                            self.tableView.reloadSections(section, withRowAnimation: .Automatic)
                            topSongFriend.setValue(friend.lastImageUpdate, forKey: "lastImageUpdate")
                            CoreDataStackManager.sharedInstance.saveContext()
                        }
                    })
                }
            }
        }
    }

}


extension TopSongsViewController: HitlistMoreButtonProtocol {
    func hitlistMoreButtonPressed(indexPath: NSIndexPath) {
        //Ask to add to hitlist
        let song = friendsArray[indexPath.section].topSongs![indexPath.row]
        let alertController = UIAlertController(title: "Add to Hitlist?", message: "\(song.title) - \(song.artist)", preferredStyle: .Alert)
        let yesAction = UIAlertAction(title: "YES", style: .Default) { (action) in
            self.sharedContext.performBlock({ 
                let hitlistSong = HitListSong(artist: song.artist, title: song.title, context: self.sharedContext)
                hitlistSong.user = self.loggedInUser!
                CoreDataStackManager.sharedInstance.saveContext()
            })
        }
        let noAction = UIAlertAction(title: "NO", style: .Default) { (action) in
            
        }
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
}




















