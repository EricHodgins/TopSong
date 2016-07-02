//
//  Friend.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-06-29.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import Foundation

struct Friend {
    var heading: String? //Friend name
    var topSongs: [TopSong]?
    var uid: String
    var imagePath: String?
    
    init(friendName: String?, friendSongs: [TopSong]?, friendID: String, storageImagePath: String?) {
        heading = friendName
        topSongs = friendSongs
        uid = friendID
        imagePath = storageImagePath
    }
}