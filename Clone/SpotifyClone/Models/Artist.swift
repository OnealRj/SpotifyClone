//
//  Artist.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/14/23.
//

import Foundation
struct Artist: Codable
{
    let id: String
    let name: String
    let type: String
    let external_urls:[String:String]
    let images: [APIImage]?
}
