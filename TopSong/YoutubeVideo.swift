//
//  YoutubeVideo.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-08-02.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import Foundation

struct YoutubeVideo {
    let title: String?
    let imageURL: String?
    let videoId: String?
    
    init(title: String?, imageURL: String?, videoId: String?) {
        self.title = title
        self.imageURL = imageURL
        self.videoId = videoId
    }
}