//
//  YoutubeImageCache.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-08-02.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit

class YoutubeImageCache {
    private var youtubeMemoryCache = NSCache()
    
    //GET images in memory
    func imageWithIdentifier(identifier: String?) -> UIImage? {
        if identifier == nil {
            return nil
        }
        
        //get image if in memory
        if let image = youtubeMemoryCache.objectForKey(identifier!) as? UIImage {
            return image
        }
        
        return nil
        
    }
    
    //Save in images in Memory
    func saveImageInMemory(image: UIImage?, withIdentifier identifier: String) {
        if image == nil {
            return
        }
        
        youtubeMemoryCache.setObject(image!, forKey: identifier)
    }
}
