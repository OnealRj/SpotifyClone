//
//  UserProfile.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/14/23.
//

import Foundation
struct UserProfile: Codable {
    let country: String
    let display_name: String
    let email: String
    let explicit_content: [String: Bool]
    let id: String
    let images: [APIImage]
    let product: String
    let type: String
    let uri: String
}
