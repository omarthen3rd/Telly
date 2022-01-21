//
//  EpisodeDetailController.swift
//  Telly
//
//  Created by Omar Abbasi on 2017-10-20.
//  Copyright © 2017 Omar Abbasi. All rights reserved.
//

import UIKit

class EpisodeDetailController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var stillImageView: UIImageView!
    @IBOutlet var episodeName: UILabel!
    @IBOutlet var airdateEpisodeNumber: UILabel!
    @IBOutlet var overview: UILabel!
    
    @IBOutlet var guestStarsCollectionView: UICollectionView!
    
    var showID = Int()
    var seasonNumber = Int()
    var episode: TVEpisode?
    var guestStars = [Person]()
    
    // MARK: - Default functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.separatorColor = UIColor.clear
        self.tableView.tableFooterView = UIView()
        
        self.navigationController?.navigationBar.backItem?.title = "Season"
        
        guard let episode = episode else { return }
        
        DispatchQueue.main.async {
            self.stillImageView.image = episode.still
        }
        
        DispatchQueue.main.async {
            // background of view + blur
            let posterBig = UIImageView(image: episode.still)
            posterBig.frame = self.view.bounds
            posterBig.contentMode = .scaleAspectFill
            posterBig.image = posterBig.image?.applyBlurWithRadius(3, tintColor: UIColor(white: 0.06, alpha: 0.73), saturationDeltaFactor: 1.8)
            posterBig.clipsToBounds = true
            self.tableView.backgroundView = posterBig
        }
        
        getEpisodeDetails(showID, episode.seasonNumber, episode.episodeNumber) { (episodeToUse) in
            
            DispatchQueue.main.async {
                self.episodeName.text = episodeToUse.name
                self.airdateEpisodeNumber.text = "\(episodeToUse.airdate) · Season \(episodeToUse.seasonNumber) Episode \(episodeToUse.episodeNumber)"
                self.overview.text = episodeToUse.overview == "" ? "No Overview Available": episodeToUse.overview
                self.tableView.reloadData()
            }
            
        }
        
        getGuestStars(showID, episode.seasonNumber, episode.episodeNumber) { (persons) in
            
            self.guestStars = persons
            
            DispatchQueue.main.async {
                
                self.guestStarsCollectionView.reloadData()
                self.tableView.reloadData()
                
            }
            
        }

    }
    
    // MARK: - Functions
    
    func getEpisodeDetails(_ showID: Int, _ seasonNumber: Int, _ episodeNumber: Int, completionHandler: @escaping (TVEpisode) -> ()) {
        
        let urlString = "https://api.themoviedb.org/3/tv/\(showID)/season/\(seasonNumber)/episode/\(episodeNumber)?api_key=562d128051ad4ff39900582f6624ca25&language=en-US"
        
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error == nil, let useableData = data {
                
                let episode = JSON(useableData)
                
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
                
                completionHandler(newEpisode)
                
            }
            
        }
        
        task.resume()
        
    }
    
    func getGuestStars(_ showID: Int, _ seasonNumber: Int, _ episodeNumber: Int, completionHandler: @escaping ([Person]) -> ()) {
        
        var persons = [Person]()
        
        let urlString = "https://api.themoviedb.org/3/tv/\(showID)/season/\(seasonNumber)/episode/\(episodeNumber)?api_key=562d128051ad4ff39900582f6624ca25&language=en-US"
        
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error == nil, let useableData = data {
                
                let json = JSON(useableData)
                
                for cast in json["guest_stars"].arrayValue {
                    
                    let id = cast["id"].intValue
                    let name = cast["name"].stringValue
                    let character = cast["character"].stringValue
                    let profileEndUrl = cast["profile_path"].stringValue
                    
                    let profile = URL(string: "https://image.tmdb.org/t/p/w500" + profileEndUrl)
                    let profileData = try? Data(contentsOf: profile!)
                    var profileImage = UIImage()
                    if let pData = profileData {
                        
                        profileImage = UIImage(data: pData)!
                        
                    } else {
                        
                        profileImage =  #imageLiteral(resourceName: "posterPlaceholder")
                        
                    }
                    
                    let newCast = Person(id: id, name: name, character: character, profile: profileImage, placeOfBirth: "", birthday: "", deathday: "", gender: nil, biography: "")
                    persons.append(newCast)
                    
                }
                
                completionHandler(persons)
                
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
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // MARK: - Collection view data source
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let person = guestStars[indexPath.row]
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "PersonDetailController") as! PersonDetailController
        vc.person = person
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.guestStars.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GuestStarsCell", for: indexPath) as! TVCastCell
        
        cell.cast = self.guestStars[indexPath.row]
        
        return cell
        
    }
    
}
