//
//  SeasonDetailController.swift
//  Telly
//
//  Created by Omar Abbasi on 2017-10-19.
//  Copyright © 2017 Omar Abbasi. All rights reserved.
//

import UIKit

class SeasonDetailController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var seasonPoster: UIImageView!
    @IBOutlet var seasonNumber: UILabel!
    @IBOutlet var overview: UILabel!
    @IBOutlet var airDateAndEpisodes: UILabel!
    
    @IBOutlet var episodesCollectionView: UICollectionView!
    @IBOutlet var collectionViewHeight: NSLayoutConstraint!
    
    var oldHeight = CGFloat()
    var show: TVShow?
    var season: TVSeason?
    var episodes = [TVEpisode]()
    
    var showID = Int()
    
    // MARK: - Default functions

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorColor = UIColor.clear
        self.tableView.tableFooterView = UIView()
        
        guard let season = season else { return }
        
        DispatchQueue.main.async {
            self.seasonPoster.image = season.poster
        }
        
        DispatchQueue.main.async {
            // background of view + blur
            let posterBig = UIImageView(image: season.poster)
            posterBig.frame = self.view.bounds
            posterBig.contentMode = .scaleAspectFill
            posterBig.image = posterBig.image?.applyBlurWithRadius(3, tintColor: UIColor(white: 0.06, alpha: 0.73), saturationDeltaFactor: 1.8)
            posterBig.clipsToBounds = true
            self.tableView.backgroundView = posterBig
        }
        
        getSeasonDetails(showID, season.seasonNumber) { (seasonToUse) in
            
            if let seasonNum = self.seasonNumber {
                
                DispatchQueue.main.async {
                    seasonNum.text = "Season \(season.seasonNumber)"
                    let airDate = self.format(season.airDate, withFormat: "MMM d, yyyy")
                    self.airDateAndEpisodes.text = "\(airDate!) · \(season.episodeCount) Episodes"
                    self.overview.text = seasonToUse.overview == "" ? "No Overview Available": seasonToUse.overview
                    self.tableView.reloadData()
                }
                
            }
            
        }
        
        getEpisodes(showID, season.seasonNumber) { (episodes) in
            
            self.episodes = episodes
            self.oldHeight = self.collectionViewHeight.constant
            
            DispatchQueue.main.async {
                
                self.episodesCollectionView.reloadData()
                self.collectionViewHeight.constant = self.episodesCollectionView.collectionViewLayout.collectionViewContentSize.height
                self.episodesCollectionView.reloadData()
                self.tableView.reloadData()
                
            }
            
        }
       
    }

    // MARK: - Functions
    
    func getSeasonDetails(_ showID: Int, _ seasonNumber: Int, completionHandler: @escaping (TVSeason) -> ()) {
        
        let urlString = "https://api.themoviedb.org/3/tv/\(showID)/season/\(seasonNumber)?api_key=562d128051ad4ff39900582f6624ca25&language=en-US"
        
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error == nil, let useableData = data {
                
                let json = JSON(useableData)
                
                let id = json["id"].intValue
                let overivew = json["overview"].stringValue
                let episodeCount = json["episodes"].arrayValue.count
                let airDate = json["air_date"].stringValue
                let seasonNumber = json["season_number"].intValue
                let posterEndURL = json["poster_path"].stringValue
                
                let poster = URL(string: "https://image.tmdb.org/t/p/w500" + posterEndURL)
                let posterData = try? Data(contentsOf: poster!)
                var posterImage = UIImage()
                if let pData = posterData {
                    
                    posterImage = UIImage(data: pData)!
                    
                } else {
                    
                    posterImage = #imageLiteral(resourceName: "posterPlaceholder")
                    
                }
                
                let newSeason = TVSeason(id: id, overview: overivew, airDate: airDate, episodeCount: episodeCount, seasonNumber: seasonNumber, poster: posterImage)
                
                completionHandler(newSeason)
                
            }
            
        }
        
        task.resume()
        
    }
    
    func getEpisodes(_ showID: Int, _ seasonNumber: Int, completionHandler: @escaping ([TVEpisode]) -> ()) {
        
        var episodes = [TVEpisode]()
        
        let urlString = "https://api.themoviedb.org/3/tv/\(showID)/season/\(seasonNumber)?api_key=562d128051ad4ff39900582f6624ca25&language=en-US"
        
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error == nil, let useableData = data {
                
                let json = JSON(useableData)
                
                for episode in json["episodes"].arrayValue {
                    
                    let name = episode["name"].stringValue
                    let overview = episode["overview"].stringValue
                    let id = episode["id"].intValue
                    let seasonNumber = episode["season_number"].intValue
                    let episodeNumber = episode["episode_number"].intValue
                    let airdate = self.format(episode["air_date"].stringValue, withFormat: "MMM d, yyyy")
                    var finalAirdate = String()
                    if let airdate = airdate {
                        finalAirdate = airdate
                    } else {
                        finalAirdate = "Airdate Not Available"
                    }
                    let rating = episode["vote_average"].doubleValue
                    let stillEndURL = episode["still_path"].stringValue
                    
                    let still = URL(string: "https://image.tmdb.org/t/p/w500" + stillEndURL)
                    let stillData = try? Data(contentsOf: still!)
                    var stillImage = UIImage()
                    if let sData = stillData {
                        
                        stillImage = UIImage(data: sData)!
                        
                    } else {
                        
                        stillImage = #imageLiteral(resourceName: "backdropPlaceholder")
                        
                    }
                    
                    let newEpisode = TVEpisode(name: name, airdate: finalAirdate, episodeNumber: episodeNumber, seasonNumber: seasonNumber, overview: overview, id: id, still: stillImage, rating: rating, guestStars: nil)
                    episodes.append(newEpisode)
                    
                }
                
                completionHandler(episodes)
                
            }
            
        }
        
        task.resume()
        
    }
    
    func format(_ showDate: String, withFormat format: String) -> String? {
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = inputFormatter.date(from: showDate) {
            
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = format
            
            return outputFormatter.string(from: date)
        }
        
        return nil
    }
    
    // MARK: - Collection view data source
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == self.episodesCollectionView {
            
            let episode = episodes[indexPath.row]
            guard let showID = show?.id else { return }
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "EpisodeDetailController") as! EpisodeDetailController
            vc.episode = episode
            vc.showID = showID
            
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return episodes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EpisodeCell", for: indexPath) as! TVEpisodeCell
        
        cell.episode = self.episodes[indexPath.row]
        
        return cell
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}
