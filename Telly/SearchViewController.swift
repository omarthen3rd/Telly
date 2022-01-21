//
//  SearchViewController.swift
//  Telly
//
//  Created by Omar Abbasi on 2017-10-02.
//  Copyright © 2017 Omar Abbasi. All rights reserved.
//

import UIKit

class SearchViewController: UITableViewController {

    var tvShows = [TVShow]()
    var resultSearchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupView() {
        
        self.resultSearchController.searchResultsUpdater = self
        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.resultSearchController.searchBar.sizeToFit()
        self.resultSearchController.searchBar.delegate = self
        self.resultSearchController.searchBar.searchBarStyle = UISearchBarStyle.minimal
        
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = self.resultSearchController
        } else {
            
            let textFieldInsideSearchBar = self.resultSearchController.searchBar.value(forKey: "searchField") as? UITextField
            textFieldInsideSearchBar?.textColor = UIColor.white
            
            self.resultSearchController.hidesNavigationBarDuringPresentation = false
            
            self.navigationItem.titleView = self.resultSearchController.searchBar
            
            definesPresentationContext = true
            
        }
        
    }
    
    func getSearchResults(_ query: String) {
        
        self.tvShows.removeAll()
        
        let urlString = "https://api.themoviedb.org/3/search/tv?api_key=562d128051ad4ff39900582f6624ca25&language=en-US&query=\(query)&page=1"
        
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error == nil, let useableData = data {
                
                let json = JSON(useableData)
                
                for result in json["results"].arrayValue {
                    
                    let id = result["id"].intValue
                    let name = result["name"].stringValue
                    let rating = result["vote_average"].doubleValue
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
                    
                    let tvShow = TVShow(id: id, name: name, overview: "", firstAirDate: "", lastAirDate: "", rating: rating, ratingCount: 0, popularity: 0, poster: posterImage, backdrop: backdropImage, originCountry: "", genre: nil, language: "", createdBy: nil, runtime: 0, website: nil, networks: [""], status: "", type: "", episodeCount: 0, seasonCount: 0, seasons: nil)
                    self.tvShows.append(tvShow)
                    
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
        }
        
        task.resume()
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tvShows.count != 0 {
            
            let currentShow = self.tvShows[indexPath.row]
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "TableViewController2") as! ShowDetailController
            vc.show = currentShow
            if #available(iOS 11.0, *) {
                vc.navigationController?.navigationBar.prefersLargeTitles = false
                vc.navigationItem.largeTitleDisplayMode = .never
            }
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tvShows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let show = self.tvShows[indexPath.row]
        
        if self.resultSearchController.isActive {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
            
            cell.textLabel?.text = show.name
            cell.textLabel?.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.semibold)
            cell.detailTextLabel?.text = "\(show.rating)"
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
            cell.imageView?.image = show.poster
            cell.imageView?.contentMode = .scaleAspectFill
            cell.imageView?.layer.cornerRadius = 5
            cell.imageView?.clipsToBounds = true
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
            cell.textLabel?.text = " "
            cell.detailTextLabel?.text = " "
            return cell
        }
        
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 75
        
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

extension SearchViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        // getSearchResults(searchController.searchBar.text!)
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        getSearchResults(searchBar.text!)
    }

    
}
