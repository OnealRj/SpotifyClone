//
//  LibraryAlbumsResponse.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 6/5/23.
//

import Foundation
struct LibraryAlbumReponse: Codable
{
    let items: [LibraryAlbumReponseItems]
}
struct LibraryAlbumReponseItems: Codable
{
    let added_at:String
    let album:Album
}
