//
//  GenresCell.swift
//  Telly
//
//  Created by Omar Abbasi on 2017-10-21.
//  Copyright © 2017 Omar Abbasi. All rights reserved.
//

import UIKit

class GenresCell: UICollectionViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    
    var genre: Genre? {
        
        didSet {
            
            guard let genre = genre else { return }
            
            self.nameLabel.text = genre.name
            self.layer.cornerRadius = 10
            self.clipsToBounds = true
            
        }
        
    }
    
}
