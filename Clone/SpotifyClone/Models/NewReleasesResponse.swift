////
////  NewReleasesResponse.swift
////  SpotifyClone
////
////  Created by Rj O'Neal on 5/17/23.
////
//
import Foundation

struct NewReleasesRespose: Codable
{
    let albums: AlbumsResponse
}

struct AlbumsResponse: Codable {
    let items: [Album]
}

