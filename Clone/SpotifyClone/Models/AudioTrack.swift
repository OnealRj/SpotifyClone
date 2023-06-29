//
//  AudioTrack.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/14/23.
//

import Foundation

struct AudioTrack: Codable
{
    var album: Album?
    let artists: [Artist]
    let available_markets:[String]
    let disc_number: Int
    let duration_ms: Int
    let explicit: Bool
    let external_urls: [String: String]
    let href: String
    let id: String
    let name:String
    let preview_url:String?
}
