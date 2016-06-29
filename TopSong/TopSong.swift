//
//  TopSong.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-06-28.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import Foundation
import MediaPlayer

protocol SongDecodable {
    var isSongPlayable: Bool { get set }
}


struct TopSong: SongDecodable {
    var artist: String
    var title: String
    var rank: String
    var mediaItem: MPMediaItem?
    var isSongPlayable: Bool
}
    
 
