//
//  HomeCollectionViewController.swift
//  Telly
//
//  Created by Omar Abbasi on 2017-09-30.
//  Copyright © 2017 Omar Abbasi. All rights reserved.
//

import UIKit

private let reuseIdentifier = "PopularShowCell"

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

extension NSMutableAttributedString {
    
    func setBoldForText(_ textToFind: String, _ fontSize: CGFloat) {
        let range = self.mutableString.range(of: textToFind, options: .caseInsensitive)
        if range.location != NSNotFound {
            let attrs = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.medium)]
            addAttributes(attrs, range: range)
        }
    }
    
    func setColorForText(_ textToFind: String, with color: UIColor) {
        let range = self.mutableString.range(of: textToFind, options: .caseInsensitive)
        if range.location != NSNotFound {
            addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range)
        }
    }
    
}

extension UIButton {
    
    func setBackgroundColor(_ color: UIColor, forState: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, for: forState)
    }
    
}

extension UIImageView {
    
    func addBlurEffect(_ style: UIBlurEffectStyle) {
        
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.addSubview(blurEffectView)
        
    }
    
}

class HomeCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var tvShows = [TVShow]()
    var didLoadAllPopularMovies = false
    var pageNumber = 1
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNeedsStatusBarAppearanceUpdate()
        
        self.collectionView?.register(GenericTVShowCell.self, forCellWithReuseIdentifier: "loadingCell")
        
        if #available(iOS 9.0, *) {
            if traitCollection.forceTouchCapability == UIForceTouchCapability.available {
                registerForPreviewing(with: self as UIViewControllerPreviewingDelegate, sourceView: collectionView!)
            }
        }
        
        getPopularTVShowsID { (success) in
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
        
    }
    
    func getPopularTVShowsID(completionHandler: @escaping (Bool) -> ()) {
        
        let urlString = "https://api.themoviedb.org/3/tv/popular?api_key=562d128051ad4ff39900582f6624ca25&language=en-US&page=\(pageNumber)"
        guard let url = URL(string: urlString) else { return }
        
        if !self.didLoadAllPopularMovies {
            
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                if error == nil, let useableData = data {
                    
                    let json = JSON(useableData)
                    
                    for result in json["results"].arrayValue {
                        
                        let id = result["id"].intValue
                        let name = result["name"].stringValue
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
                        
                        let tvShow = TVShow(id: id, name: name, overview: "", firstAirDate: "", lastAirDate: "", rating: 0, ratingCount: 0, popularity: 0, poster: posterImage, backdrop: backdropImage, originCountry: "", genre: nil, language: "", createdBy: nil, runtime: 0, website: nil, networks: [""], status: "", type: "", episodeCount: 0, seasonCount: 0, seasons: nil)
                        self.tvShows.append(tvShow)
                        
                    }
                    
                }
                
                completionHandler(true)
                
            }
            task.resume()
            
        }
        
    }
    
    func loadingCell() -> GenericTVShowCell {
        
        let cell = GenericTVShowCell()
        self.collectionView?.register(GenericTVShowCell.self, forCellWithReuseIdentifier: "loadingCell")
        // cell.showPoster.image = #imageLiteral(resourceName: "posterPlaceholder")
        // cell.showName.text = "Load More"
        cell.isUserInteractionEnabled = false
        cell.tag = 1337
        return cell
        
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if cell.tag == 1337 {
            if !(tvShows.isEmpty) {
                self.pageNumber += 1
                self.getPopularTVShowsID(completionHandler: { (success) in
                    
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                    
                })
            }
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let show = tvShows[indexPath.row]
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "TableViewController2") as! ShowDetailController
        vc.show = show
        if #available(iOS 11.0, *) {
            vc.navigationController?.navigationBar.prefersLargeTitles = false
            vc.navigationItem.largeTitleDisplayMode = .never
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return tvShows.count + 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row < self.tvShows.count {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GenericTVShowCell
            
            let show = tvShows[indexPath.row]
            
            cell.show = show
            
            return cell
            
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "loadingCell", for: indexPath) as! GenericTVShowCell
            
            cell.isUserInteractionEnabled = false
            cell.tag = 1337
            
            return cell
        }
        
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = CGSize(width: (collectionView.frame.size.width / 3.5), height: 170)
        return size
    }

}

extension HomeCollectionViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = collectionView?.indexPathForItem(at: location), let cell = collectionView?.cellForItem(at: indexPath) as? GenericTVShowCell else {
            return nil
        }
        
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "TableViewController2") as? ShowDetailController else {
            return nil
        }
        
        let show = tvShows[indexPath.row]
        detailVC.show = show
        previewingContext.sourceRect = cell.bounds
        
        return detailVC
        
    }
    
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        self.navigationController?.pushViewController(viewControllerToCommit, animated: true)
        
    }
    
}
