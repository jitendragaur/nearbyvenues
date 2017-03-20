//
//  VeneusViewController.swift
//  nearByVenues
//
//  Created by Jitendra Gaur on 3/17/17.
//  Copyright © 2017 Jitendra Gaur. All rights reserved.
//

import UIKit
import CoreLocation

class VeneusViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var venues = [Venue]()
        
    let cellIdentifire = "VenusTableViewCell"
    
    var currentLocation = CLLocation()
    var locationManager = CLLocationManager()
    
    @IBAction func buttonRefreshTapped(_ sender: Any) {
        requestUserLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        locationManager.delegate = self
    }
    
    
    func requestUserLocation() {
        
        HelperMethods.showActivityIndicatory(label: "Aquiring location...")
        locationManager.requestLocation() //request only one time
    }
    
    func fetchVenuesFromAPI(location: CLLocation?) {
        
        HelperMethods.hideActivityIndicatory()
        
        HelperMethods.showActivityIndicatory(label: "Fetching venues...")
        
        var currentLocation = "37.329700,-121.888145"
        
        if let location = location {
            currentLocation = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        }
        
        APIService.getVenues(currentLocation: currentLocation) { venues in
            self.venues = venues.sorted(by: {$0.0.location.distance < $0.1.location.distance})
            
            DispatchQueue.main.async {
                HelperMethods.hideActivityIndicatory()
                self.tableView.reloadData()
            }            
        }
    }    
    
}

extension VeneusViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifire, for: indexPath) as! VenusTableViewCell
        
        cell.separatorInset = .zero
        
        let venue = venues[indexPath.row]
        
        cell.labelName.text = venue.name
        let distance = venue.location.distance
        cell.labelDistance.text = distance < 1000 ? "\(distance)m" : "\(distance/1000)Km"
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let detailVC = mainStoryBoard.instantiateViewController(withIdentifier: "VenueDetailViewController") as! VenueDetailViewController
        detailVC.venue = venues[indexPath.row]
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
}

extension VeneusViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        fetchVenuesFromAPI(location: locations.first)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        HelperMethods.hideActivityIndicatory()
        
        let alert = UIAlertController(title: "Location error", message: "Error while fetching the location", preferredStyle: .alert)
        
        let refreshAction = UIAlertAction(title: "Refresh", style: .default) { action in
            self.requestUserLocation()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(refreshAction)
        alert.addAction(cancelAction)
        
        if #available(iOS 9.0, *) {
            alert.preferredAction = refreshAction
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse, .authorizedAlways:
            requestUserLocation()
            break

        case .restricted, .denied:
            let alert = UIAlertController(title: "Enable Location", message: "Please enable location servervices for this app", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
}
