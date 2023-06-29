//
//  SearchResult.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/29/23.
//

import Foundation
enum SearchResult
{
    case artist(model: Artist)
    case album(model: Album)
    case track(model: AudioTrack)
    case playlist(model: PlaylistItem)
}
