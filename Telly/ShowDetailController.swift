//
//  ShowDetailController.swift
//  Telly
//
//  Created by Omar Abbasi on 2017-10-06.
//  Copyright © 2017 Omar Abbasi. All rights reserved.
//

import UIKit

class ShowDetailController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var showName: UILabel!
    @IBOutlet var showRating: UILabel!
    @IBOutlet var showSeasons: UILabel!
    @IBOutlet var infoButton: UIButton!
    @IBOutlet var seasonsButton: UIButton!
    @IBOutlet var overviewLabel: UILabel!
    @IBOutlet var episodeRuntime: UILabel!
    @IBOutlet var showNetworks: UILabel!
    @IBOutlet var showGenres: UILabel!
    
    @IBOutlet var seasonsCollectionView: UICollectionView!
    @IBOutlet var seasonsCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet var castCollectionView: UICollectionView!
    @IBOutlet var similiarShowsCollectionView: UICollectionView!
    
    var imgAvgColor = UIColor()
    var imgContrastColor = UIColor()
    
    var show: TVShow?
    var credits = [Person]()
    var seasons = [TVSeason]()
    var similiarShows = [TVShow]()
    
    // MARK: - Default functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.castCollectionView.delegate = self
        self.castCollectionView.dataSource = self
        
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.separatorColor = UIColor.clear
        self.tableView.tableFooterView = UIView()
        
        self.loadData()
        
    }
    
    // MARK: - Functions
    
    func loadData() {
        
        guard let show = show else { return }
        guard let name = showName else { return }
        guard let rating = showRating else { return }
        guard let seasons = showSeasons else { return }
        guard let overview = overviewLabel else { return }
        guard let runtime = episodeRuntime else { return }
        guard let network = showNetworks else { return }
        guard let genres = showGenres else { return }
        
        name.text = show.name
        
        DispatchQueue.main.async {
            
            // tableView background poster
            let posterBig = UIImageView(image: show.poster)
            posterBig.frame = self.view.bounds
            posterBig.contentMode = .scaleAspectFill
            posterBig.clipsToBounds = true
            self.tableView.backgroundView = posterBig
            posterBig.image = posterBig.image?.applyBlurWithRadius(3, tintColor: UIColor(white: 0.06, alpha: 0.73), saturationDeltaFactor: 1.8)
            
            // avg colorbackground of view
            self.imgAvgColor = UIColor.flatBlackColor()
            self.imgContrastColor = UIColor.contrastColor(self.imgAvgColor, true)
            
            if let info = self.infoButton {
                info.setTitle("INFO", for: UIControlState.normal)
                info.setBackgroundColor(self.imgContrastColor, forState: .highlighted)
                info.setTitleColor(self.imgAvgColor, for: .highlighted)
                info.setBackgroundColor(self.imgAvgColor, forState: .normal)
                info.setTitleColor(self.imgContrastColor, for: .normal)
                info.addTarget(self, action: #selector(self.switchTab(_:)), for: .touchUpInside)
                info.isHighlighted = true
                info.tag = 1
            }
            if let season = self.seasonsButton {
                season.setTitle("SEASONS", for: UIControlState.normal)
                season.setBackgroundColor(self.imgContrastColor, forState: .highlighted)
                season.setTitleColor(self.imgAvgColor, for: .highlighted)
                season.setBackgroundColor(self.imgAvgColor, forState: .normal)
                season.setTitleColor(self.imgContrastColor, for: .normal)
                season.addTarget(self, action: #selector(self.switchTab(_:)), for: .touchUpInside)
                season.tag = 0
            }
            
        }
        
        getTVShowDetails(show.id) { (showToUse) in
            
            rating.attributedText = self.attributeText("\(showToUse.rating)/10", "\(showToUse.rating)", [.bold, .color], UIColor.white)
            
            // if season count != 1, then use "Seasons" in label, else use "Season" in label
            seasons.attributedText = showToUse.seasonCount != 1 ? self.attributeText("\(showToUse.seasonCount) Seasons", "\(showToUse.seasonCount)", [.bold, .color], UIColor.white) : self.attributeText("\(showToUse.seasonCount) Season", "\(showToUse.seasonCount)", [.bold, .color], UIColor.white)
            
            overview.text = showToUse.overview
            runtime.attributedText = self.attributeText("\(showToUse.runtime) min /episode", "\(showToUse.runtime) min", [.bold, .color], UIColor.white)
            
            guard let genresArr = showToUse.genre else { return }
            genres.text = ""
            var i = 0
            for genre in genresArr {
                // if index == 1, then don't use "/" in label: else use "/" in label
                genres.text = i == 0 ? genres.text! + "\(genre.name)" : genres.text! + " / \(genre.name)"
                i += 1
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
        
        getSeasons(show.id) { (seasons) in
            
            self.seasons = seasons
            
            DispatchQueue.main.async {
                self.seasonsCollectionView.reloadData()
                self.seasonsCollectionViewHeight.constant = self.seasonsCollectionView.collectionViewLayout.collectionViewContentSize.height
                self.seasonsCollectionView.reloadData()
            }
            
        }
        
        getCredits(show.id) { (persons) in
            
            self.credits = persons
            
            DispatchQueue.main.async {
                self.castCollectionView.reloadData()
            }
            
        }
        
        getSimiliarShows(show.id) { (similiarShows) in
            
            self.similiarShows = similiarShows
            
            DispatchQueue.main.async {
                self.similiarShowsCollectionView.reloadData()
            }
            
        }
        
    }
    
    func getTVShowDetails(_ showID: Int, completionHandler: @escaping (TVShow) -> ()) {
        
        let urlString = "https://api.themoviedb.org/3/tv/\(showID)?api_key=562d128051ad4ff39900582f6624ca25&language=en-US"
        
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error == nil, let useableData = data {
                
                DispatchQueue.main.async {
                    
                    let json = JSON(useableData)
                    
                    let name = json["name"].stringValue
                    let id = json["id"].intValue
                    let voteCount = json["vote_count"].intValue
                    let rating = json["vote_average"].doubleValue
                    let overview = json["overview"].stringValue
                    let popularity = json["popularity"].doubleValue
                    let posterEndURL = json["poster_path"].stringValue
                    let backdropEndURL = json["backdrop_path"].stringValue
                    guard let showHomePage = URL(string: json["homepage"].stringValue) else { return }
                    let status = json["status"].stringValue
                    let firstAirDate = json["first_air_date"].stringValue
                    let lastAirDate = json["last_air_date"].stringValue
                    let episodeRuntime = json["episode_run_time"][0].intValue
                    let episodeCount = json["number_of_episodes"].intValue
                    let seasonCount = json["number_of_seasons"].intValue
                    
                    let poster = URL(string: "https://image.tmdb.org/t/p/w500" + posterEndURL)
                    let backdrop = URL(string: "https://image.tmdb.org/t/p/w500" + backdropEndURL)
                    
                    let posterData = try? Data(contentsOf: poster!)
                    var posterImage = UIImage()
                    if let pData = posterData {
                        
                        posterImage = UIImage(data: pData)!
                        
                    } else {
                        
                        posterImage = #imageLiteral(resourceName: "backdropPlaceholder")
                        
                    }
                    
                    let backdropData = try? Data(contentsOf: backdrop!)
                    var backdropImage = UIImage()
                    if let bgData = backdropData {
                        
                        backdropImage = UIImage(data: bgData)!
                        
                    } else {
                        
                        backdropImage = #imageLiteral(resourceName: "backdropPlaceholder")
                        
                    }
                    
                    
                    var genres = [Genre]()
                    for genre in json["genres"].arrayValue {
                        
                        let id = genre["id"].intValue
                        let name = genre["name"].stringValue
                        let newGenre = Genre(id: id, name: name)
                        genres.append(newGenre)
                        
                    }
                    
                    let newShow = TVShow(id: id, name: name, overview: overview, firstAirDate: firstAirDate, lastAirDate: lastAirDate, rating: rating, ratingCount: voteCount, popularity: popularity, poster: posterImage, backdrop: backdropImage, originCountry: "", genre: genres, language: "", createdBy: nil, runtime: episodeRuntime, website: showHomePage, networks: [""], status: status, type: "", episodeCount: episodeCount, seasonCount: seasonCount, seasons: nil)
                    
                    completionHandler(newShow)
                    
                }
                
            }
            
        }
        task.resume()
        
    }
    
    func getCredits(_ showID: Int, completionHandler: @escaping ([Person]) -> ()) {
        
        var persons = [Person]()
        
        let urlString = "https://api.themoviedb.org/3/tv/\(showID)/credits?api_key=562d128051ad4ff39900582f6624ca25&language=en-US"
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error == nil, let useableData = data {
                
                let json = JSON(useableData)
                
                for cast in json["cast"].arrayValue {
                    
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
                        
                        profileImage = #imageLiteral(resourceName: "posterPlaceholder")
                        
                    }
                    
                    let newCast = Person(id: id, name: name, character: character, profile: profileImage, placeOfBirth: "", birthday: "", deathday: "", gender: nil, biography: "")
                    persons.append(newCast)
                    
                }
                
                completionHandler(persons)
                
            }
            
        }
        
        task.resume()
        
    }
    
    func getSeasons(_ showID: Int, completionHandler: @escaping ([TVSeason]) -> ()) {
        
        var seasons = [TVSeason]()
        
        let urlString = "https://api.themoviedb.org/3/tv/\(showID)?api_key=562d128051ad4ff39900582f6624ca25&language=en-US"
        
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error == nil, let useableData = data {
                
                let json = JSON(useableData)
                
                for season in json["seasons"].arrayValue {
                    
                    let id = season["id"].intValue
                    let episodeCount = season["episode_count"].intValue
                    let airDate = season["air_date"].stringValue
                    let seasonNumber = season["season_number"].intValue
                    let posterEndURL = season["poster_path"].stringValue
                    
                    let poster = URL(string: "https://image.tmdb.org/t/p/w500" + posterEndURL)
                    let posterData = try? Data(contentsOf: poster!)
                    var posterImage = UIImage()
                    if let pData = posterData {
                        
                        posterImage = UIImage(data: pData)!
                        
                    } else {
                        
                        posterImage = #imageLiteral(resourceName: "posterPlaceholder")
                        
                    }
                    
                    let newSeason = TVSeason(id: id, overview: "", airDate: airDate, episodeCount: episodeCount, seasonNumber: seasonNumber, poster: posterImage)
                    seasons.append(newSeason)
                    
                }
                
                completionHandler(seasons)
                
            }
            
        }
        task.resume()
        
    }
    
    func getSimiliarShows(_ showID: Int, completionHandler: @escaping ([TVShow]) -> ()) {
        
        var similiarShows = [TVShow]()
        
        let urlString = "https://api.themoviedb.org/3/tv/\(showID)/similar?api_key=562d128051ad4ff39900582f6624ca25&language=en-US&page=1"
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
                    similiarShows.append(tvShow)
                    
                }
                
            }
            
            completionHandler(similiarShows)
            
        }
        task.resume()
        
        
    }
    
    @objc func switchTab(_ sender: UIButton) {
        
        switch sender {
        case infoButton:
            infoButton.tag = 1
            seasonsButton.tag = 0
            infoButton.setBackgroundColor(self.imgContrastColor, forState: .normal)
            infoButton.setTitleColor(self.imgAvgColor, for: .normal)
            infoButton.isHighlighted = true
            seasonsButton.setBackgroundColor(self.imgAvgColor, forState: .normal)
            seasonsButton.setTitleColor(self.imgContrastColor, for: .normal)
            seasonsButton.isHighlighted = false
            // overviewCell.isHidden = false
            // seasonsCell.isHidden = true
            DispatchQueue.main.async {
                self.infoButton.sizeToFit()
                self.tableView.reloadData()
            }
        case seasonsButton:
            seasonsButton.tag = 1
            infoButton.tag = 0
            seasonsButton.setBackgroundColor(self.imgContrastColor, forState: .normal)
            seasonsButton.setTitleColor(self.imgAvgColor, for: .normal)
            seasonsButton.isHighlighted = true
            infoButton.setBackgroundColor(self.imgAvgColor, forState: .normal)
            infoButton.setTitleColor(self.imgContrastColor, for: .normal)
            infoButton.isHighlighted = false
            // seasonsCell.isHidden = false
            // overviewCell.isHidden = true
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        default:
            break
        }
        
    }
    
    func attributeText(_ text: String, _ textToAttribute: String, _ attributes: [Attributes], _ color: UIColor?) -> NSMutableAttributedString {
        
        let attributedString = NSMutableAttributedString(string: text)
        
        if attributes.contains(.bold) && attributes.contains(.color) {
            
            // attributes has both bold and color
            attributedString.setBoldForText(textToAttribute, 21)
            attributedString.setColorForText(textToAttribute, with: color!)
            
        } else if attributes.contains(.bold) {
            
            // attributes only has bold
            attributedString.setBoldForText(textToAttribute, 21)
            
        } else {
            
            // attributes only has color
            attributedString.setColorForText(textToAttribute, with: color!)
            
        }
        
        return attributedString
        
    }
    
    // MARK: - Table view
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.infoButton.tag == 1 && indexPath.row == 3 {
            return 0
        } else if self.seasonsButton.tag == 1 && indexPath.row == 2 {
            return 0
        }
        return UITableViewAutomaticDimension
    }
    
    // MARK: - Collection view
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == self.seasonsCollectionView {
            
            let season = seasons[indexPath.row]
            guard let showID = show?.id else { return }
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "SeasonDetailController") as! SeasonDetailController
            vc.season = season
            vc.show = show
            vc.showID = showID
            
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else if collectionView == self.castCollectionView {
            
            let person = credits[indexPath.row]
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "PersonDetailController") as! PersonDetailController
            vc.person = person
            
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            
            let show = similiarShows[indexPath.row]
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "TableViewController2") as! ShowDetailController
            vc.show = show
            if #available(iOS 11.0, *) {
                vc.navigationController?.navigationBar.prefersLargeTitles = false
                vc.navigationItem.largeTitleDisplayMode = .never
            }
            
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.castCollectionView {
            return self.credits.count
        } else if collectionView == self.seasonsCollectionView {
            return self.seasons.count
        } else {
            return self.similiarShows.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.castCollectionView {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CastCell", for: indexPath) as! TVCastCell
            
            cell.cast = self.credits[indexPath.row]
            
            return cell
            
        } else if collectionView == self.seasonsCollectionView {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SeasonCell", for: indexPath) as! GenericTVShowCell
            
            cell.season = self.seasons[indexPath.row]
            
            return cell
            
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SimiliarShowsCell", for: indexPath) as! LargeTVShowCell
            
            cell.show = self.similiarShows[indexPath.row]
            
            return cell
            
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == self.similiarShowsCollectionView {
            
            let size = CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
            return size
            
        } else {
            
            let size = CGSize(width: (collectionView.frame.size.width / 3.5), height: 175)
            return size
            
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
