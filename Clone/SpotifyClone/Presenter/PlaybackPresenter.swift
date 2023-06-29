//
//  PlaybackPresenter.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/31/23.
//
import AVFoundation
import Foundation
import UIKit

protocol PlayerDataSource: AnyObject
{
    var songName: String? {get}
    var subtitle: String? {get}
    var imageURL: URL? {get}
}
final class PlaybackPresenter
{
    static let shared = PlaybackPresenter()
    
    private var track: AudioTrack?
    private var tracks: [AudioTrack] = [AudioTrack]()
    private var player: AVPlayer?
    private var playerQueue: AVQueuePlayer?
    private var playerVC: PlayerViewController?
    private var index: Int = 0
    
    var currentTrack: AudioTrack? {
        if let track = track, tracks.isEmpty{
            return track
        }
        else if let player = self.playerQueue, !tracks.isEmpty
        {
            return self.tracks[index]
        }
        return nil
    }
    
    private init()
    {
        
    }
    
    func startPlayback(from viewController: UIViewController, track: AudioTrack)
    {
        guard let url = URL(string: track.preview_url ?? "") else
        {
            return
        }
        self.player = AVPlayer(url: url)
        player?.volume = 0.5
        self.track = track
        self.tracks = []
        let vc = PlayerViewController()
        vc.title = track.name
        vc.dataSource = self
        vc.delegate = self
        viewController.present(UINavigationController(rootViewController: vc), animated: true) { [weak self] in
            self?.player?.play()
        }
        self.playerVC = vc
        
    }
    
    func startPlayback(from viewController: UIViewController, tracks: [AudioTrack])
    {
        self.track = nil
        self.tracks = tracks
        let items: [AVPlayerItem] = tracks.compactMap({
            guard let url = URL(string: $0.preview_url ?? "") else {return nil}
            return AVPlayerItem(url: url)
        })
        
        self.playerQueue = AVQueuePlayer(items: items)
        self.playerQueue?.volume = 0.5
        self.playerQueue?.play()
        let vc = PlayerViewController()
        vc.dataSource = self
        vc.delegate = self
        viewController.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
        self.playerVC = vc
    }
    
}

extension PlaybackPresenter: PlayerDataSource
{
    var songName: String? {
        return currentTrack?.name
    }
    
    var subtitle: String? {
        return currentTrack?.artists.first?.name
    }
    
    var imageURL: URL? {
        print(currentTrack?.album?.images)
        return URL(string: currentTrack?.album?.images.first?.url ?? "")
    }
}

extension PlaybackPresenter: PlayerViewControllerDelegate
{
    func didTapPlayPause() {
        if let player = self.player
        {
            if player.timeControlStatus == .playing
            {
                player.pause()
            }
            else if player.timeControlStatus == .paused
            {
                player.play()
            }
        }
        else if let player = playerQueue
        {
            if player.timeControlStatus == .playing
            {
                player.pause()
            }
            else if player.timeControlStatus == .paused
            {
                player.play()
            }
        }
    }
    
    func didTapBackward() {
        if tracks.isEmpty
        {
            // Not Playlist or album
            player?.pause()
        }
        else if let firstItem = playerQueue?.items().first
        {
            playerQueue?.pause()
            playerQueue?.removeAllItems()
            playerQueue = AVQueuePlayer(items: [firstItem])
            playerQueue?.play()
            playerQueue?.volume = 0.5
        }
    }
    
    func didTapForward() {
        if tracks.isEmpty
        {
            // Not Playlist or album
            player?.pause()
        }
        else if let player = playerQueue{
            player.advanceToNextItem()
            self.index += 1
            playerVC?.refreshUI()
        }
    }
    
    func didSlideSlider(_ value: Float) {
        player?.volume = value
    }
    
}
