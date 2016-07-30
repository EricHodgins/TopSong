//
//  User.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-07-13.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import Foundation
import CoreData

class User : NSManagedObject {
    
    @NSManaged var userId : String
    @NSManaged var topSongFriends : [TopSongFriend]
    @NSManaged var hitListSongs : [HitListSong]
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(userId: String, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.userId = userId
    }
    
    
    
}
