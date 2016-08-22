//
//  TopSongFriend.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-07-13.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import Foundation
import CoreData

class TopSongFriend: NSManagedObject {
    
    @NSManaged var imageFilePath : String
    @NSManaged var lastImageUpdate : NSDate
    @NSManaged var friendId: String
    @NSManaged var user : User
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(friendId: String, imageFilePath: String?, lastImageUpdate: NSDate?, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("TopSongFriend", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        if let imageFilePath = imageFilePath {
            self.imageFilePath = imageFilePath
        } else {
            self.imageFilePath = ""
        }
        
        self.friendId = friendId
        
        if let lastImageUpdate = lastImageUpdate {
            self.lastImageUpdate = lastImageUpdate
        } else {
            self.lastImageUpdate = NSDate()
        }
        
    }
    
    override func prepareForDeletion() {
        //Delete Profile Image in Documents Directory
        let fileManager = NSFileManager.defaultManager()
        let fullImagePath = getPathToDocumentsDirectory(friendId)
        do {
            try fileManager.removeItemAtPath(fullImagePath)
        } catch {
            print("could not delete friend: \(fullImagePath)")
        }
    }
    
    //MARK: Helper
    func getPathToDocumentsDirectory(imagePath: String) -> String {
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(imagePath)
        
        return fullURL.path!
    }
}
