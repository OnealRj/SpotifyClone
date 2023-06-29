//
//  AlbumDetailsReponse.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/25/23.
//

import Foundation
struct AlbumDetailsReponse: Codable
{
    let album_type: String
    let artists:[Artist]
    let available_markets: [String]
    let external_urls: [String:String]
    let images: [APIImage]
    let id: String
    let label:String
    let name:String
    let release_date: String
    let tracks:TracksResponse
}
