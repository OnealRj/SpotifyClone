//
//  Owner.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/22/23.
//

import Foundation

struct Owner: Codable
{
    let external_urls:[String:String]
    let followers: Followers?
    let href:String
    let id:String
    let type:String
    let uri:String
    let display_name:String
}
