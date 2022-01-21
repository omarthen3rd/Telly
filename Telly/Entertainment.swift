//
//  Entertainment.swift
//  Telly
//
//  Created by Omar Abbasi on 2017-09-29.
//  Copyright © 2017 Omar Abbasi. All rights reserved.
//

import Foundation
import UIKit

struct TVShow {
    
    var id: Int
    var name: String
    var overview: String
    var firstAirDate: String
    var lastAirDate: String
    var rating: Double
    var ratingCount: Int
    var popularity: Double
    var poster: UIImage
    var backdrop: UIImage
    var originCountry: String
    var genre: [Genre]?
    var language: String
    var createdBy: [Person]?
    var runtime: Int
    var website: URL?
    var networks: [String]
    var status: String
    var type: String
    var episodeCount: Int
    var seasonCount: Int
    var seasons: [TVSeason]?
    
}

struct TVSeason {
    
    var id: Int
    var overview: String
    var airDate: String
    var episodeCount: Int
    var seasonNumber: Int
    var poster: UIImage
    
}

struct TVEpisode {
    
    var name: String
    var airdate: String
    var episodeNumber: Int
    var seasonNumber: Int
    var overview: String
    var id: Int
    var still: UIImage
    var rating: Double
    var guestStars: [Person]?
    
}

struct Genre {
    
    var id: Int
    var name: String
    
}

struct Person {
    
    var id: Int
    var name: String
    var character: String?
    var profile: UIImage
    var placeOfBirth: String
    var birthday: String
    var deathday: String
    var gender: Gender?
    var biography: String
    
}

enum CollectionEn {
    
    case castCollection
    case seasonCollection
    
}

enum Attributes {
    
    case bold
    case color
    
}

enum Gender {
    
    case male
    case female
    case other
    
}
