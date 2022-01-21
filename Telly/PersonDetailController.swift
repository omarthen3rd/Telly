//
//  PersonDetailController.swift
//  Telly
//
//  Created by Omar Abbasi on 2017-10-22.
//  Copyright © 2017 Omar Abbasi. All rights reserved.
//

import UIKit

class PersonDetailController: UITableViewController {
    
    var person: Person?

    @IBOutlet var personName: UILabel!
    @IBOutlet var personPhoto: UIImageView!
    @IBOutlet var personBirthdate: UILabel!
    @IBOutlet var personPlaceOfBirth: UILabel!
    @IBOutlet var personBiography: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.separatorColor = UIColor.clear
        self.tableView.tableFooterView = UIView()
        
        guard let person = person else { return }
        
        self.personName.text = person.name
        self.personPhoto.image = person.profile
        
        DispatchQueue.main.async {
            // background of view + blur
            let posterBig = UIImageView(image: person.profile)
            posterBig.frame = self.view.bounds
            posterBig.contentMode = .scaleAspectFill
            posterBig.image = posterBig.image?.applyBlurWithRadius(6, tintColor: UIColor(white: 0.06, alpha: 0.73), saturationDeltaFactor: 1.8)
            posterBig.clipsToBounds = true
            self.tableView.backgroundView = posterBig
        }
        
        getPersonDetails(person.id) { (personToUse) in
            
            self.personBiography.text = personToUse.biography
            self.personBirthdate.text = personToUse.birthday
            self.personPlaceOfBirth.text = personToUse.placeOfBirth
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
        
    }
    
    func getPersonDetails(_ id: Int, completionHandler: @escaping (Person) -> ()) {
        
        let urlString = "https://api.themoviedb.org/3/person/\(id)?api_key=562d128051ad4ff39900582f6624ca25&language=en-US"
        
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error == nil, let useableData = data {
                
                let cast = JSON(useableData)
                
                let id = cast["id"].intValue
                let name = cast["name"].stringValue
                let character = cast["character"].stringValue
                let birthday = self.format(cast["birthday"].stringValue, withFormat: "MMM dd, yyyy")
                let deathday = self.format(cast["deathday"].stringValue, withFormat: "MMM dd, yyyy")
                let placeOfBirth = cast["place_of_birth"].stringValue
                let profileEndUrl = cast["profile_path"].stringValue
                let genderInt = cast["gender"].intValue
                let gender = genderInt == 1 ? Gender.female : Gender.male
                let biography = cast["biography"].stringValue
                
                let profile = URL(string: "https://image.tmdb.org/t/p/w500" + profileEndUrl)
                let profileData = try? Data(contentsOf: profile!)
                var profileImage = UIImage()
                if let pData = profileData {
                    
                    profileImage = UIImage(data: pData)!
                    
                } else {
                    
                    profileImage = #imageLiteral(resourceName: "posterPlaceholder")
                    
                }
                
                let finalDeathDay = deathday == nil ? "Not Dead Yet" : deathday!
                
                let newCast = Person(id: id, name: name, character: character, profile: profileImage, placeOfBirth: placeOfBirth, birthday: birthday!, deathday: finalDeathDay, gender: gender, biography: biography)
                
                completionHandler(newCast)
                
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
    
    
    
}
