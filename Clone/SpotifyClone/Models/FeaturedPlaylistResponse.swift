//
//  FeaturedPlaylistResponse.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/21/23.
//

import Foundation
struct FeaturedPlaylistResponse: Codable
{
    let message: String?
    let playlists: Playlist
}
struct Playlist: Codable
{
    let href: String
    let items: [PlaylistItem]
}
