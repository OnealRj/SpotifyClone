//
//  SearchResultResponse.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/29/23.
//

import Foundation
struct SearchResultResponse: Codable
{
    let albums: SearchAlbumResponse
    let artists: SearchArtistResponse
    let playlists: SearchPlaylistResponse
    let tracks: SearchTracksReponse
}
struct SearchAlbumResponse: Codable
{
    let href:String
    let items:[Album]
}
struct SearchArtistResponse: Codable
{
    let href:String
    let items:[Artist]
}
struct SearchPlaylistResponse: Codable
{
    let href:String
    let items:[PlaylistItem]
}
struct SearchTracksReponse: Codable
{
    let href:String
    let items:[AudioTrack]
}
//struct SearchAlbumsItem: Codable
//{
//    let album_type:String
//    let total_tracks:Int
//    let artists:[Artist]
//    let available_markets:String
//    let external_urls:[String:String]
//    let href:String
//    let id:String
//    let images:[APIImage]
//    let release_date:String
//    let uri:String
//}
//struct SearchArtistItem: Codable
//{
//    let external_urls:[String: String]?
//    let name:String?
//    let id:String?
//    let images:[APIImage]?
//}
//struct SearchPlaylistItem: Codable
//{
//    let name:String?
//    let description:String?
//    let href:String?
//    let id:String?
//    let images:[APIImage]?
//
//}
//
