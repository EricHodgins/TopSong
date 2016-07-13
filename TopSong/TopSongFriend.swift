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
    @NSManaged var user : User
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(imageFilePath: String, lastImageUpdate: NSDate, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("TopSongFriend", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.imageFilePath = imageFilePath
        self.lastImageUpdate = lastImageUpdate
    }
    
}
