//
//  SongProtocols.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-06-12.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import Foundation
import MediaPlayer

protocol SongChanging: class {
    func changingNewTopSongAt(indexPath: NSIndexPath)
}

protocol SongPicking: class {
    func pickedNewTopSong(song: TopSong, forIndexPath: NSIndexPath)
}

protocol HitlistMoreButtonProtocol: class {
    func hitlistMoreButtonPressed(indexPath: NSIndexPath)
}