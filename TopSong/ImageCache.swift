//
//  ImageCache.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-07-09.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit

class ImageCache {
    private var inMemoryCache = NSCache()
    
    //MARK: Get Images
    func imageWithIdentifier(identifier: String?) -> UIImage? {
        
        if identifier == nil || identifier == "" {
            return nil
        }
        
        let path = pathForIdentifier(identifier!)
        
        //Check to see it's in memory cache already
        if let image = inMemoryCache.objectForKey(path) as? UIImage {
            return image
        }
        
        // If not, check to see if it's on the hard drive
        if let data = NSData(contentsOfFile: path) {
            let image = UIImage(data: data)
            inMemoryCache.setObject(image!, forKey: path)
            
            return UIImage(data: data)
        }
        
        return nil
    }
    
    
    //MARK: Save Images to Documents Directory
    func storeImage(image: UIImage?, withIdentifier identifier: String) {
        let path = pathForIdentifier(identifier)
        
        if image == nil {
            inMemoryCache.removeObjectForKey(path)
            
            do {
                try NSFileManager.defaultManager().removeItemAtPath(path)
            } catch {}
            
            return
        }
        
        //Cache the image now
        inMemoryCache.setObject(image!, forKey: path)
        
        //Now put in Documents Directory
        let data = UIImageJPEGRepresentation(image!, 0.1)!
        data.writeToFile(path, atomically: true)  
        
    }
    
    //MARK: Remove Image
    func removeImage(forPath path: String) {
        let fileManager = NSFileManager.defaultManager()
        let fullImagePath = pathForIdentifier(path)
        
        do {
            //Remove from storage
            try fileManager.removeItemAtPath(fullImagePath)
            //If that works, remove from cache as well.
            inMemoryCache.removeObjectForKey(fullImagePath)
        } catch let error as NSError {
            print("could not delete imaget for path: \(fullImagePath) - \(error)")
        }
    }
    
    
    func pathForIdentifier(identifier: String) -> String {
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identifier)
        
        return fullURL.path!
    }
}
