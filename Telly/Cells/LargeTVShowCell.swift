//
//  LargeTVShowCell.swift
//  Telly
//
//  Created by Omar Abbasi on 2017-10-22.
//  Copyright © 2017 Omar Abbasi. All rights reserved.
//

import UIKit
import CyaneaOctopus

class LargeTVShowCell: UICollectionViewCell {
    
    @IBOutlet var cellContainerView: UIView!
    @IBOutlet var showPoster: UIImageView!
    @IBOutlet var showName: UILabel!
    @IBOutlet var showRating: UILabel!
    @IBOutlet var showOverview: UILabel!
    
    var show: TVShow? {
        
        didSet {
            
            guard let show = show else { return }
            
            let avgColor = UIColor.flatBlueColor()
            let contrastColor = UIColor.contrastingBlackOrWhiteColorOn(avgColor, isFlat: true, alpha: 1.0)
            
            cellContainerView.backgroundColor = avgColor
            showPoster.image = show.poster
            showName.text = show.name
            showRating.attributedText = self.attributeText("\(show.rating)/10", "\(show.rating)", [.bold, .color], contrastColor)
            showOverview.text = show.overview
            showOverview.numberOfLines = 0
            
            setColor(contrastColor)
            
        }
        
    }
    
    func setColor(_ color: UIColor) {
        
        showName.textColor = color
        showRating.textColor = color
        showOverview.textColor = color
        
    }
    
    func attributeText(_ text: String, _ textToAttribute: String, _ attributes: [Attributes], _ color: UIColor?) -> NSMutableAttributedString {
        
        let attributedString = NSMutableAttributedString(string: text)
        
        if attributes.contains(.bold) && attributes.contains(.color) {
            
            // attributes has both bold and color
            attributedString.setBoldForText(textToAttribute, 18)
            attributedString.setColorForText(textToAttribute, with: color!)
            
        } else if attributes.contains(.bold) {
            
            // attributes only has bold
            attributedString.setBoldForText(textToAttribute, 18)
            
        } else {
            
            // attributes only has color
            attributedString.setColorForText(textToAttribute, with: color!)
            
        }
        
        return attributedString
        
    }
    
}

