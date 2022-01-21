//
//  GenericTVShowCell.swift
//  Telly
//
//  Created by Omar Abbasi on 2017-09-29.
//  Copyright © 2017 Omar Abbasi. All rights reserved.
//

import UIKit

class GenericTVShowCell: UICollectionViewCell {
    
    @IBOutlet var showPoster: UIImageView!
    @IBOutlet var showName: UILabel!
    
    var show: TVShow? {
        
        didSet {
            
            guard let show = show else { return }
            
            showPoster.image = show.poster
            showName.text = show.name
            
        }
        
    }
    
    var season: TVSeason? {
        
        didSet {
            
            guard let season = season else { return }
                        
            showPoster.image = season.poster
            showName.text = "Season \(season.seasonNumber)"
            
            if showName.text == "Season 0" {
               showName.text = "Specials"
            }
            
        }
        
    }
    
}
