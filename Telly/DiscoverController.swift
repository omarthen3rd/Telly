//
//  DiscoverController.swift
//  Telly
//
//  Created by Omar Abbasi on 2017-10-21.
//  Copyright © 2017 Omar Abbasi. All rights reserved.
//

import UIKit

private let reuseIdentifier = "GenreCell"

class DiscoverController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var genres = [Genre]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getGenres()
        
    }
    
    func getGenres() {
        
        let urlString = "https://api.themoviedb.org/3/genre/tv/list?api_key=562d128051ad4ff39900582f6624ca25&language=en-US"
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error == nil, let useableData = data {
                
                let json = JSON(useableData)
                
                for genre in json["genres"].arrayValue {
                    
                    let id = genre["id"].intValue
                    let name = genre["name"].stringValue
                    
                    let newGenre = Genre(id: id, name: name)
                    self.genres.append(newGenre)
                    
                }
                
                DispatchQueue.main.async {
                    
                    self.collectionView?.reloadData()
                    
                }
                
            }
            
        }
        task.resume()
        
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let genre = genres[indexPath.row]
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "GenreDetailController") as! GenreDetailController
        vc.genre = genre
        // vc.modalPresentationStyle = .overCurrentContext
        // vc.modalPresentationCapturesStatusBarAppearance = true
        
        self.navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return genres.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GenresCell
    
        cell.backgroundColor = UIColor.flatBlackColor()
        cell.genre = self.genres[indexPath.row]
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
                
        let size = CGSize(width: ((collectionView.frame.size.width / 2) - 16), height: 70)
        return size
    }

}
