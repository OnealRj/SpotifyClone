//
//  LibraryPlaylistResponse.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 6/2/23.
//

import Foundation

struct LibraryPlaylistsReponse: Codable
{
    let href: String
    let items: [PlaylistItem]
}
