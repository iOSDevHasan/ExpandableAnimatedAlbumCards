//
//  AlbumModel.swift
//  PodcastAlbumCards
//
//  Created by HASAN BERAT GURBUZ on 10.10.2024.
//

import Foundation

struct Album: Identifiable {
    var id: UUID = .init()
    var name: String
    var image: String
    var isLiked = false
}

var albumCards: [Album] = [
    Album(name: "Thunder", image: "albumcover1"),
    Album(name: "Rock", image: "albumcover2"),
    Album(name: "Peace", image: "albumcover3"),
    Album(name: "YES!", image: "albumcover4"),
    Album(name: "OMG", image: "albumcover5")
]
