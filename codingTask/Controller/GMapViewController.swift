//
//  GMapViewController.swift
//  codingTask
//
//  Created by Parimala Ranganath Velayudam on 11/06/18.
//  Copyright © 2018 VPR productions. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class GMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    var locationManager = CLLocationManager()
    var currentLocation = LocationDataModel()
   
 
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    
    func updateMapUI() {
        let latitude = currentLocation.locCoords.coordinate.latitude
        let longitude = currentLocation.locCoords.coordinate.longitude
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 15.0)
        mapView.camera = camera
    }
    
    func addCurrentLocationMarker() {
        let latitude = currentLocation.locCoords.coordinate.latitude
        let longitude = currentLocation.locCoords.coordinate.longitude
        let marker = GMSMarker()
        marker.icon = GMSMarker.markerImage(with: UIColor(displayP3Red: 0.33, green: 1.00, blue: 0.10, alpha: 1.0))
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.title = currentLocation.title
        marker.snippet = currentLocation.snippet
        marker.map = mapView
    }
    
    //Reverse geocode to fetch the address of current location
    func getAddress(coords: CLLocation) {
        
        var adressString : String = ""
        CLGeocoder().reverseGeocodeLocation(coords) { (placemark, error) in
            if error != nil {
                
                print("Reverse geocode error")
                
            } else {
                
                let place = placemark! as [CLPlacemark]
                
                if place.count > 0 {
                    let place = placemark![0]
                    
                    if place.thoroughfare != nil {
                        adressString = adressString + place.thoroughfare! + ", "
                    }
                    if place.subThoroughfare != nil {
                        adressString = adressString + place.subThoroughfare! + "\n"
                    }
                    if place.locality != nil {
                        self.currentLocation.title = place.locality!
                        adressString = adressString + place.locality! + " - "
                    }
                    if place.postalCode != nil {
                        adressString = adressString + place.postalCode! + "\n"
                    }
                    if place.subAdministrativeArea != nil {
                        adressString = adressString + place.subAdministrativeArea! + " - "
                    }
                    if place.country != nil {
                        adressString = adressString + place.country!
                    }
                    
                    self.currentLocation.snippet = adressString
                    self.addCurrentLocationMarker()
                }
                
            }
        }
        
    }
}


// MARK: Location manager delegate methods - capturing current location
extension GMapViewController: CLLocationManagerDelegate {
    
    // incoming  events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location: CLLocation = locations.last!
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            currentLocation.locCoords = location
            getAddress(coords: location)
            updateMapUI()
        }
    }
    
    // authorization
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    //  errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    
}

