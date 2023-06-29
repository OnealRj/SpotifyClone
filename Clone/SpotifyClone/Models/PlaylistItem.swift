//
//  PlaylistItem.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/25/23.
//

import Foundation
struct PlaylistItem: Codable
{
    let collaborative: Bool
    let description: String
    let external_urls: [String:String]
    let href: String
    let id: String
    let images: [APIImage]?
    let name: String
    let uri: String
    let owner:Owner
}
