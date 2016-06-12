//
//  SongPickerViewController.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-06-08.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit
import MediaPlayer

class SongPickerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var songPickedCallback: ((String, String, NSIndexPath) -> ())?
    weak var delegate: SongPicking?
    var pickedNumberAtIndexPath: NSIndexPath?
    
    let cellSongTitleAttribute = UIFont.chalkboardFont(withSize: 20.0)
    let cellSongTitleColorAttribute = UIColor().darkBlueAppDesign
    let cellArtistColorAttribute = UIColor().lightBlueAppDesign
    let cellArtistFontAttribute = UIFont.chalkboardFont(withSize: 15.0)
    
    @IBOutlet weak var tableView: UITableView!
    
    var mediaItems = [MPMediaItem]()
    var filteredSongs = [MPMediaItem]()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        searchController.searchResultsUpdater = self
        searchController.loadViewIfNeeded()
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.barTintColor = UIColor().lightBlueAppDesign
        tableView.tableHeaderView = searchController.searchBar
        
        tableView.backgroundColor = UIColor.clearColor()
        
        mediaItems = MPMediaQuery.songsQuery().items!
        
        UIView.animateWithDuration(1.0) {
            self.view.alpha = 1.0
        }
        
    }
    
    deinit {
        print("songPickerViewController was deallocated.")
    }
    
    
    func filterSongsForSearchText(searchText: String, scope: String = "Title") {
        filteredSongs = mediaItems.filter({ (song) -> Bool in
            return song.title!.lowercaseString.containsString(searchText.lowercaseString)
        })
        
        tableView.reloadData()
    }
    

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.active && searchController.searchBar.text != "" {
            return filteredSongs.count
        }
        
        return mediaItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("pickerCell", forIndexPath: indexPath)
        let song: MPMediaItem
        
        if searchController.active && searchController.searchBar.text != "" {
            song = filteredSongs[indexPath.row]
        } else {
            song = mediaItems[indexPath.row]
        }
        
        cell.textLabel?.attributedText = NSAttributedString(string: song.title!, attributes: [NSFontAttributeName: cellSongTitleAttribute, NSForegroundColorAttributeName: cellSongTitleColorAttribute])
        cell.detailTextLabel?.attributedText = NSAttributedString(string: song.artist!, attributes: [NSFontAttributeName: cellArtistFontAttribute, NSForegroundColorAttributeName: cellArtistColorAttribute])
        
        return cell
        
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let song: MPMediaItem
        if searchController.active && searchController.searchBar.text != "" {
            song = filteredSongs[indexPath.row]
        } else {
            song = mediaItems[indexPath.row]
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.delegate?.pickedNewTopSong(song, forIndexPath: self.pickedNumberAtIndexPath!)
            
            if self.searchController.active {
                self.searchController.dismissViewControllerAnimated(true, completion: nil)
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    

    @IBAction func doneButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}


extension SongPickerViewController: UISearchResultsUpdating {
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterSongsForSearchText(searchController.searchBar.text!)
    }
    
    
}






























