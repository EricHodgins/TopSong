//
//  YoutubeClient.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-08-02.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit

class YoutubeClient {
    
    let apiKey: String = "AIzaSyD_dVrbcgU7AjRFqrAYF0YFsIpYl_YF5bU"
    let videoBaseStringURL: String = "https://www.youtube.com/watch?v="

    func getYoutubeVideoData(withSearchString searchString: String, completionHandler: (success: Bool, youtubeVideos: [YoutubeVideo]) -> Void) {
        let encodedURLString = searchString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
        let youtubeURLStringRequest = "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=40&q=\(encodedURLString)&key=\(apiKey)"
        let youtubeURL = NSURL(string: youtubeURLStringRequest)!
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(youtubeURL) { (data, response, error) in
            self.parseJSONData(data, completionHandler: completionHandler)
        }
        
        task.resume()
        
    }
    
    func parseJSONData(data: NSData?, completionHandler: (sucess: Bool, youtubeVideos: [YoutubeVideo]) -> Void) {
        
        do {
            guard data != nil else {
                completionHandler(sucess: false, youtubeVideos: [])
                return
            }
            
            if let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? [String : AnyObject] {
                var youtubeVideos = [YoutubeVideo]()
                let items = jsonData["items"] as! [[String : AnyObject]]
                for item in items {
                    let id = item["id"] as! [String : AnyObject]
                    guard let videoId = id["videoId"] as? String else {
                        continue
                    }
                    
                    let snippet = item["snippet"] as! [String : AnyObject]
                    let title = snippet["title"] as! String
                    let thumbnails = snippet["thumbnails"] as! [String : AnyObject]
                    let defaultImageSettings = thumbnails["default"] as! [String : AnyObject]
                    let defaultImageURL = defaultImageSettings["url"] as! String
                    
                    let video = YoutubeVideo(title: title, imageURL: defaultImageURL, videoId: videoId)
                    youtubeVideos.append(video)
                }
                
                completionHandler(sucess: true, youtubeVideos: youtubeVideos)
            }
        } catch let error as NSError {
            print("Error parsing youtube data: \(error.localizedDescription)")
        }
    }
    
    
    func getYoutubeImage(withURL url: String, completionHandler: (success: Bool, image: UIImage?) -> Void) -> NSURLSessionTask {
        let imageURL = NSURL(string: url)!
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(imageURL) { (imageData, response, error) in
            if imageData != nil {
                if let image = UIImage(data: imageData!) {
                    dispatch_async(dispatch_get_main_queue()) {
                        completionHandler(success: true, image: image)
                    }
                }
            }
        }
        
        task.resume()
        return task
    }
    
    //HELPER
    
    func makeURLToWatchVideoOnYoutube(videoId: String) -> NSURL {
        let urlString = videoBaseStringURL + videoId
        
        return NSURL(string: urlString)!
    }
    
}
