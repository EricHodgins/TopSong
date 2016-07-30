//
//  HitListSong.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-07-13.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import Foundation
import CoreData

class HitListSong: NSManagedObject {
    @NSManaged var artist: String
    @NSManaged var title: String
    @NSManaged var user: User
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(artist: String, title: String, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("HitListSong", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.artist = artist
        self.title = title
    }
}