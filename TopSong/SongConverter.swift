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
    
    func getAudioFileFromSystemWithSongsArray(songsArray: NSArray) -> [TopSong?] {
        
        // audio references may or may not exist.  If they existed on the phone/ipod then playable otherwise not immediately playable
        
        var audioReferences = [TopSong?]()
        
        for (index, song) in songsArray.enumerate() {
            
            guard let songDict = song as? [String : String] else {
                audioReferences.append(nil)
                continue
            }
            
            //songDict = song as! [String : String]
            let title = songDict["songTitle"]!
            let artist = songDict["songArtist"]!
            
            let titlePredicate = MPMediaPropertyPredicate(value: title, forProperty: MPMediaItemPropertyTitle)
            let artistPredicate = MPMediaPropertyPredicate(value: artist, forProperty: MPMediaItemPropertyArtist)
            
            let query: MPMediaQuery = MPMediaQuery.songsQuery()
            query.addFilterPredicate(titlePredicate)
            query.addFilterPredicate(artistPredicate)
            
            if query.items?.count > 0 {
                let songMediaItem = query.items![0]
                let topSong = TopSong(artist: artist, title: title, rank: "\(index)", mediaItem: songMediaItem, isSongPlayable: true)
                audioReferences.append(topSong)
            } else {
                let topSong = TopSong(artist: artist, title: title, rank: "\(index)", mediaItem: nil, isSongPlayable: false)
                audioReferences.append(topSong)
            }
            
            
        }
        
        return audioReferences
    }
    
    /// generateTopSong: Creates a TopSong.  Tries to find a song on the device. If it doesn't then it's marked as unplayable.
    func generateTopSong(artist: String, title: String, rank: String) -> TopSong {
        let titlePredicate = MPMediaPropertyPredicate(value: title, forProperty: MPMediaItemPropertyTitle)
        let artistPredicate = MPMediaPropertyPredicate(value: artist, forProperty: MPMediaItemPropertyArtist)
        let query = MPMediaQuery.songsQuery()
        query.addFilterPredicate(titlePredicate)
        query.addFilterPredicate(artistPredicate)
        
        let topSong: TopSong
        
        if query.items?.count > 0 {
            let songMediaItem = query.items?[0]
            topSong = TopSong(artist: artist, title: title, rank: rank, mediaItem: songMediaItem, isSongPlayable: true)
        } else {
            topSong = TopSong(artist: artist, title: title, rank: rank, mediaItem: nil, isSongPlayable: false)
        }
        
        return topSong
    }
}

