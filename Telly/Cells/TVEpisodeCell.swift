//
//  TVEpisodeCell.swift
//  Telly
//
//  Created by Omar Abbasi on 2017-10-01.
//  Copyright © 2017 Omar Abbasi. All rights reserved.
//

import UIKit

class TVEpisodeCell: UICollectionViewCell {
    
    @IBOutlet var episodePoster: UIImageView!
    @IBOutlet var episodeName: UILabel!
    @IBOutlet var episodeInfo: UILabel!
    @IBOutlet var episodeRating: CosmosView!
    
    var episode: TVEpisode? {
        
        didSet {
            
            guard let episode = episode else { return }
    
            episodePoster.image = episode.still
            episodeName.text = "Season \(episode.seasonNumber) Episode \(episode.episodeNumber) · \(episode.airdate)  ·"
            episodeRating.settings.textColor = UIColor.black
            episodeRating.text = "\(episode.rating.rounded())"
            episodeInfo.text = episode.name
            
            DispatchQueue.main.async {
                self.layer.cornerRadius = 10
                self.clipsToBounds = true
            }
            
        }
        
    }
    
}
