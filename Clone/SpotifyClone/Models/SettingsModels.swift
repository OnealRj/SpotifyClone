//
//  SettingsModels.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/16/23.
//

import Foundation

struct Section
{
    let title: String
    let options:[Option]
}
struct Option
{
    let title: String
    let handler: () -> Void
}
