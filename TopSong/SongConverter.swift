//
//  SongConverter.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-06-28.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import Foundation
import MediaPlayer

class SongConverter {
    
    func getAudioFileFromSystemWithSongsArray(songsArray: NSArray) -> [TopSong] {
        
        // audio references may or may not exist.  If they existed on the phone/ipod then playable otherwise not immediately playable
        
        var audioReferences = [TopSong]()
        
        for (index, song) in songsArray.enumerate() {
            let songDict = song as! [String : String]
            let title = songDict["songTitle"]!
            let artist = songDict["songArtist"]!
            
            let titlePredicate = MPMediaPropertyPredicate(value: title, forProperty: MPMediaItemPropertyTitle)
            let artistPredicate = MPMediaPropertyPredicate(value: artist, forProperty: MPMediaItemPropertyArtist)
            
            let query: MPMediaQuery = MPMediaQuery.songsQuery()
            query.addFilterPredicate(titlePredicate)
            query.addFilterPredicate(artistPredicate)
            
            if let songMediaItem = query.items?[0] {
                let topSong = TopSong(artist: artist, title: title, rank: "\(index)", mediaItem: songMediaItem, isSongPlayable: true)
                audioReferences.append(topSong)
            } else {
                let topSong = TopSong(artist: artist, title: title, rank: "\(index)", mediaItem: nil, isSongPlayable: false)
                audioReferences.append(topSong)
            }
            
            
        }
        
        return audioReferences
    }
}

