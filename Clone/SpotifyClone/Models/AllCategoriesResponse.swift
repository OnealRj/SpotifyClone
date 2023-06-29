//
//  AllCategoriesResponse.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/28/23.
//

import Foundation

struct AllCategoriesReponse: Codable
{
    let categories: CategoryReponse
}

struct CategoryReponse: Codable
{
    let href:String
    let items: [CategoryReponseItem]
}

struct CategoryReponseItem: Codable
{
    let href:String
    let icons: [APIImage]
    let id:String
    let name:String
}
