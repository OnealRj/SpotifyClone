//
//  PlaylistDetailResponse.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/25/23.
//

import Foundation
struct PlaylistDetailResponse: Codable
{
    let collaborative: Bool
    let description: String
    let external_urls: [String: String]
    let images:[APIImage]
    let owner: Owner
    let tracks: PlaylistDetailTrackResponse
    let uri:String
}
struct PlaylistDetailTrackResponse: Codable
{
    let items:[PlaylistDetailTrackItem]
}
struct PlaylistDetailTrackItem: Codable
{
    let track:AudioTrack
}
