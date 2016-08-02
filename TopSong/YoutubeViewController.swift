//
//  YoutubeViewController.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-08-01.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit

class YoutubeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var youtubeClient = YoutubeClient()
    var hitlistSong: HitListSong?
    var youtubeVideos = [YoutubeVideo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        getYoutubeVideoData()
        
        print(hitlistSong)
    }
    
    func getYoutubeVideoData() {
        youtubeClient.getYoutubeVideoData(withSearchString: "\(hitlistSong!.artist) \(hitlistSong!.title)") { (success, youtubeVideos) in
            if success {
                self.youtubeVideos = youtubeVideos
                self.tableView.reloadData()
            }
        }
    }
}

extension YoutubeViewController {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return youtubeVideos.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! YoutubeTableViewCell
        let video = youtubeVideos[indexPath.row]
        
        cell.songTitle.text = video.title
        
        youtubeClient.getYoutubeImage(withURL: video.imageURL!, identifier: "", cell: cell, atIndexPath: indexPath)
        
        
        return cell
    }
}

































