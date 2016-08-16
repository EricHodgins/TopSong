//
//  MusicProtocols.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-08-11.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit

protocol SoundBarAnimatable: class {
    var animatingCellIndex:NSIndexPath? { get set }
}