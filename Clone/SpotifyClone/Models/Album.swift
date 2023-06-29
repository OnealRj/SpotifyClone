//
//  Album.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/19/23.
//

import Foundation

struct Album: Codable {
    let album_type: String
    let external_urls: [String:String]
    let available_markets:[String]
    let id: String
    var images:[APIImage]
    let name: String
    let release_date: String
    let total_tracks: Int
    let artists:[Artist]
}
