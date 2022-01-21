//
//  TVCastCell.swift
//  Telly
//
//  Created by Omar Abbasi on 2017-10-02.
//  Copyright © 2017 Omar Abbasi. All rights reserved.
//

import UIKit

class TVCastCell: UICollectionViewCell {
    
    @IBOutlet var profile: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var character: UILabel!
    
    var cast: Person? {
        
        didSet {
            
            guard let cast = cast else { return }
            
            profile.image = cast.profile
            name.text = cast.name
            character.text = cast.character
            
        }
        
    }
    
}
