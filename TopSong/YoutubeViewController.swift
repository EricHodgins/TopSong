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
    var activityView: UIActivityIndicatorView!
    
    var youtubeClient = YoutubeClient()
    var hitlistSong: HitListSong?
    var youtubeImageCache: YoutubeImageCache?
    var youtubeVideos = [YoutubeVideo]()
    
    var loadingView: UIView!
    var blurEffectView: UIVisualEffectView!
    
    var presentingAlertMessage: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Youtube Videos"
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont.chalkboardFont(withSize: 20.0), NSForegroundColorAttributeName: UIColor.whiteColor()]
        loadingView = UIView(frame: self.view.frame)
        
        let blurEffect = UIBlurEffect(style: .Light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.frame
        view.addSubview(blurEffectView)
        
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .White)
        activityView.color = UIColor().darkBlueAppDesign
        activityView.frame = CGRect(x: loadingView.frame.width / 2, y: loadingView.frame.height / 2, width: 20, height: 20)
        activityView.startAnimating()
        blurEffectView.addSubview(activityView)
        
        tableView.delegate = self
        tableView.dataSource = self
        getYoutubeVideoData()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(YoutubeViewController.showNetworkErrorMessage), name: networkErrorNotificationKey, object: nil)
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func getYoutubeVideoData() {
        youtubeClient.getYoutubeVideoData(withSearchString: "\(hitlistSong!.artist) \(hitlistSong!.title)") { (success, youtubeVideos) in
            if success {
                self.youtubeVideos = youtubeVideos
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                    self.animateBlurViewAway()
                }
            } else {
                print("error getting youtube data.")
                self.showNetworkErrorMessage()
            }
        }
    }
    
    func showNetworkErrorMessage() {
        if presentingAlertMessage == false {
            dispatch_async(dispatch_get_main_queue()) {
                self.activityView.stopAnimating()
                self.showMessage("Network Error", message: "Looks like there is a network problem. Check your connection.")
            }
        }
    }
    
    func showMessage(title: String, message: String?) {
        presentingAlertMessage = true
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

    
    func animateBlurViewAway() {
        UIView.animateWithDuration(2.0, animations: {
            self.blurEffectView.alpha = 0
            }) { (finished) in
                self.blurEffectView.removeFromSuperview()
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
        cell.youtubeImageView.image = UIImage(named: "TopSongAppIcon Copy")
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
        let task = youtubeClient.getYoutubeImage(withURL: video.imageURL!) { (success, image) in
            if success {
                let visibleCell = self.tableView.cellForRowAtIndexPath(indexPath) as? YoutubeTableViewCell
                if visibleCell != nil {
                    cell.youtubeImageView.image = image
                }
                //cache the image now
                self.youtubeImageCache?.saveImageInMemory(image, withIdentifier: video.videoId!)
            }
        }
        
        cell.sessionTaskToCancelIfCellIsReused = task
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let video = youtubeVideos[indexPath.row]
        let youtubeVideoURL = youtubeClient.makeURLToWatchVideoOnYoutube(video.videoId!)
        UIApplication.sharedApplication().openURL(youtubeVideoURL)
    }
}

































