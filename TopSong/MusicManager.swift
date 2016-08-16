//
//  MusicManager.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-08-11.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import Foundation
import MediaPlayer

class MusicManager {
    
    enum MusicState {
        case Play
        case Pause
        case Stop
    }
    
    
    static let sharedInstance = MusicManager()
    
    var musicPlayer = MPMusicPlayerController.systemMusicPlayer()
    var currentlyPlayingMediaItem: MPMediaItem?
    var animatingCellIndexPath: NSIndexPath?
    var topSongsViewController: TopSongsViewController?
    var profileViewController: ProfileViewController?
    
    private init() {
        MPMusicPlayerController.systemMusicPlayer().beginGeneratingPlaybackNotifications()
        musicPlayer.beginGeneratingPlaybackNotifications()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MusicManager.handleMusicPlayerStateChange), name: MPMusicPlayerControllerPlaybackStateDidChangeNotification, object: musicPlayer)
        
    }
    
    func playMusic(topSong: TopSong, ViewController: SoundBarAnimatable) -> MusicState {
        
        guard topSong.mediaItem != nil else {
            return .Stop
        }
        
        if ViewController is TopSongsViewController {
            profileViewController!.animatingCellIndex = nil
        } else if topSongsViewController != nil {
            topSongsViewController!.animatingCellIndex = nil
        }
        
        
        if currentlyPlayingMediaItem == nil {
            currentlyPlayingMediaItem = topSong.mediaItem!
        } else if currentlyPlayingMediaItem! == topSong.mediaItem! {
            stopMusic()
            currentlyPlayingMediaItem = nil
            return .Stop
        }
        
        currentlyPlayingMediaItem = topSong.mediaItem!
        let mediaColletion = MPMediaItemCollection(items: [topSong.mediaItem!])
        musicPlayer.setQueueWithItemCollection(mediaColletion)
        musicPlayer.repeatMode = .None
        musicPlayer.play()
        return .Play
    
    }
    
    func stopMusic() {
        musicPlayer.stop()
    }
    
    @objc func handleMusicPlayerStateChange() {
        print("Music player State changed: \(musicPlayer.playbackState.rawValue)")
        
        switch musicPlayer.playbackState {
        case .Stopped:
            print("Stopped.")
            if let topSongsViewController = topSongsViewController {
                topSongsViewController.animatingCellIndex = nil
            }
            
            if let profileViewController = profileViewController {
                profileViewController.animatingCellIndex = nil
            }
            
        case .Playing:
            print("Playing")
            
        case .Paused:
            print("Paused.")
        case .Interrupted:
            print("Interrupted.")
        default:
            print("something else.")
        }
    }
    
}





























