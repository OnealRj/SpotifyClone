//
//  CategoryPlaylistResponse.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/28/23.
//

import Foundation
struct CategoryPlaylistResponse: Codable
{
    let message: String?
    let playlists: Playlist
}

