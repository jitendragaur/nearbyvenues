//
//  APIService.swift
//  nearByVenues
//
//  Created by Jitendra Gaur on 3/17/17.
//  Copyright © 2017 Jitendra Gaur. All rights reserved.
//

import Foundation


struct APIService {
        
    static func getVenues(currentLocation: String, completion: @escaping (_ : [Venue]) -> Void)  {
    
        let searchURL = Constants.ForeSqure_API.URL + "venues/search/?v=20130815"
            + "&client_id=" + Constants.ForeSqure_API.CLIENT_ID
            + "&client_secret=" + Constants.ForeSqure_API.CLIENT_SECRET
            + "&ll=" + currentLocation
        
        let task = URLSession.shared.dataTask(with: URL(string: searchURL)!) { ( data, response, error) in
            
            guard let data = data, let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) else {
                print("error while fetching data")
                return
            }
            
            if let apiJSON = jsonData as? [String: Any], let response = apiJSON["response"] as? [String: Any], let venues = response["venues"] as? [[String: Any]] {
                completion(venues.map({Venue(jsonData: $0)}))
            }
        }
        
        task.resume()
    }
}
