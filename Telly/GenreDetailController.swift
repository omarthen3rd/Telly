//
//  GenreDetailController.swift
//  Telly
//
//  Created by Omar Abbasi on 2017-10-21.
//  Copyright © 2017 Omar Abbasi. All rights reserved.
//

import UIKit

class GenreDetailController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var genre: Genre?
    var popularTVShows = [TVShow]()
    
    @IBOutlet var popularTVCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.popularTVCollectionView.delegate = self
        self.popularTVCollectionView.dataSource = self
        
        self.tableView.backgroundColor = UIColor(hexString: "1C1C1C")
        self.tableView.separatorColor = UIColor.clear
        self.tableView.tableFooterView = UIView()
        
        guard let genre = genre else { return }
        
        self.title = genre.name
        
        getPopularGenreShows(genre.id)
        
    }
    
    func getPopularGenreShows(_ id: Int) {
        
        let urlString = "https://api.themoviedb.org/3/discover/tv?api_key=562d128051ad4ff39900582f6624ca25&language=en-US&sort_by=popularity.desc&page=1&with_genres=\(id)&include_null_first_air_dates=false"
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error == nil, let useableData = data {
                
                let json = JSON(useableData)
                
                for result in json["results"].arrayValue {
                    
                    let id = result["id"].intValue
                    let name = result["name"].stringValue
                    let rating = result["vote_average"].doubleValue
                    let overview = result["overview"].stringValue
                    let posterEndURL = result["poster_path"].stringValue
                    let backdropEndURL = result["backdrop_path"].stringValue
                    
                    let poster = URL(string: "https://image.tmdb.org/t/p/w500" + posterEndURL)
                    let backdrop = URL(string: "https://image.tmdb.org/t/p/w500" + backdropEndURL)
                    
                    let posterData = try? Data(contentsOf: poster!)
                    var posterImage = UIImage()
                    if let pData = posterData {
                        
                        posterImage = UIImage(data: pData)!
                        
                    } else {
                        
                        posterImage = #imageLiteral(resourceName: "posterPlaceholder")
                        
                    }
                    
                    let backdropData = try? Data(contentsOf: backdrop!)
                    var backdropImage = UIImage()
                    if let bgData = backdropData {
                        
                        backdropImage = UIImage(data: bgData)!
                        
                    } else {
                        
                        backdropImage = #imageLiteral(resourceName: "backdropPlaceholder")
                        
                    }
                    
                    let tvShow = TVShow(id: id, name: name, overview: overview, firstAirDate: "", lastAirDate: "", rating: rating, ratingCount: 0, popularity: 0, poster: posterImage, backdrop: backdropImage, originCountry: "", genre: nil, language: "", createdBy: nil, runtime: 0, website: nil, networks: [""], status: "", type: "", episodeCount: 0, seasonCount: 0, seasons: nil)
                    self.popularTVShows.append(tvShow)
                    
                }
                
                DispatchQueue.main.async {
                    self.popularTVCollectionView.reloadData()
                }
                
            }
            
        }
        task.resume()
        
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // MARK: - Collection view data source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let show = popularTVShows[indexPath.row]
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "TableViewController2") as! ShowDetailController
        vc.show = show
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.popularTVShows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularShowCell", for: indexPath) as! LargeTVShowCell
        
        cell.show = self.popularTVShows[indexPath.row]
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
        return size
    }

}
