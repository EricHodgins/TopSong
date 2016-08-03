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
    var youtubeImageCache: YoutubeImageCache?
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
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
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
        
        cell.songTitle.attributedText = UIDesign.darkStyleAttributedString(video.title!, fontSize: 20.0)
        getYoutubeVideoImage(cell, video: video, atIndexPath: indexPath)
        
        return cell
    }
    
    func getYoutubeVideoImage(cell: YoutubeTableViewCell, video: YoutubeVideo, atIndexPath indexPath: NSIndexPath) {
        // 1st check youtubeimage cache
        let cachedImage = youtubeImageCache?.imageWithIdentifier(video.videoId!)
        if cachedImage != nil {
            dispatch_async(dispatch_get_main_queue()) {
                let visibleCell = self.tableView.cellForRowAtIndexPath(indexPath) as? YoutubeTableViewCell
                if visibleCell != nil {
                    visibleCell!.youtubeImageView.image = cachedImage!
                }
            }
            
            return
        }
        
        // If not in cache download it from youtube API
        youtubeClient.getYoutubeImage(withURL: video.imageURL!) { (success, image) in
            if success {
                cell.youtubeImageView.image = image
                //cache the image now
                self.youtubeImageCache?.saveImageInMemory(image, withIdentifier: video.videoId!)
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let video = youtubeVideos[indexPath.row]
        let youtubeVideoURL = youtubeClient.makeURLToWatchVideoOnYoutube(video.videoId!)
        UIApplication.sharedApplication().openURL(youtubeVideoURL)
    }
}

































