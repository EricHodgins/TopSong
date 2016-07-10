//
//  TopSongsViewController.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-06-17.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit
import Firebase

class TopSongsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UserInfoUpdating {
    
    let firebaseClient = FirebaseClient.sharedInstance


    var user: FIRUser?
    
    @IBOutlet weak var tableView: UITableView!

    var friendsArray = [Friend]()
    var refreshControl: UIRefreshControl!
    
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
        hideStars(cell)
        
        
        let song = friendsArray[indexPath.section].topSongs![indexPath.row]
        
        cell.titleLabel.attributedText = UIDesign.darkStyleAttributedString(song.title, fontSize: 20.0)
        cell.artistLabel.attributedText = UIDesign.lightStyleAttributedString(song.artist, fontSize: 15.0)
        
        unHideStars(song.rank, cell: cell)
        
        
        return cell
    }
    
    func hideStars(cell: TopSongTableViewCell) {
        cell.star1.hidden = true
        cell.star2.hidden = true
        cell.star3.hidden = true
    }
    
    func unHideStars(rankString: String, cell: TopSongTableViewCell) {
        let rank = Int(rankString)!
        
        if rank == 0 {
            cell.star1.hidden = false
        } else if rank == 1 {
            cell.star1.hidden = false
            cell.star2.hidden = false
        } else {
            cell.star1.hidden = false
            cell.star2.hidden = false
            cell.star3.hidden = false
        }
    }
    
    func drawStars(rank: String, cell: TopSongTableViewCell) {
        let rankNumber = Int(rank)!
        let starImage = UIImage(named: "ic_star")
        var rightAnchorConstant: CGFloat = 0
        
        for _ in 0...rankNumber {
            let starImageView = UIImageView(image: starImage)
            starImageView.translatesAutoresizingMaskIntoConstraints = false
            starImageView.contentMode = .ScaleAspectFill
            cell.addSubview(starImageView)
            
            rightAnchorConstant -= 8
            starImageView.rightAnchor.constraintEqualToAnchor(cell.rightAnchor, constant: rightAnchorConstant).active = true
            starImageView.topAnchor.constraintEqualToAnchor(cell.topAnchor, constant: 5).active = true
            starImageView.heightAnchor.constraintEqualToConstant(10).active = true
            starImageView.widthAnchor.constraintEqualToConstant(10).active = true
        }
    }
    
    
    //MARK: Download Songs/Friend Info
    
    func endTableViewRefreshing() {
        print("ended table view refreshing.")
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
            var indexPaths = [NSIndexPath]()
            if friend.topSongs != nil {
                for (index, _) in friend.topSongs!.enumerate() {
                    let ip = NSIndexPath(forRow: index, inSection: self.friendsArray.count - 1)
                    indexPaths.append(ip)
                }
            }
            self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
            self.tableView.endUpdates()
        }
    }

}























