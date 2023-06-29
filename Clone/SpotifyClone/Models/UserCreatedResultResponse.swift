//
//  UserCreatedResultResponse.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 6/2/23.
//

import Foundation

struct UserCreatedResultResponse: Codable
{
    let collaborative: Bool?
    let description:String?
    let external_urls: [String:String]
    let href:String?
    let id:String?
    let images: [APIImage]?
    let owner:Owner
}
