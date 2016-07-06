//
//  ProfileProtocols.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-07-05.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import Foundation

protocol UserInfoUpdating {
    func upatedFriendProfileNameAndImage(friendID: String, newName: String?)
    func endTableViewRefreshing()
    func updateFriendSongChange(friendID: String, newTopSong: TopSong, rank: Int)
}

