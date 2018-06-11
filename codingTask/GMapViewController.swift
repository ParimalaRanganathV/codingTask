//
//  ViewController.swift
//  codingTask
//
//  Created by Parimala Ranganath Velayudam on 11/06/18.
//  Copyright © 2018 VPR productions. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class GMapViewController: UIViewController {
    
    var locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    var mapView: GMSMapView!
   
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
    }
    
    

}

extension GMapViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        currentLocation = location
        print("Location: \(location)")
        getAdressName(coords: currentLocation)
       
    
      
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    func updateMapBasedOnCurrentLocation(currLocAdd:String) {
        
        let latitude = currentLocation.coordinate.latitude
        let longitude = currentLocation.coordinate.longitude
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 15.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        
        // Marker at current location
        let marker = GMSMarker()
        marker.icon = GMSMarker.markerImage(with: UIColor(displayP3Red: 0.33, green: 1.00, blue: 0.10, alpha: 1.0))
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.title = "you are here"
        marker.snippet = currLocAdd
        marker.map = mapView
    }
    
    
    func getAdressName(coords: CLLocation) {
            
        var adressString : String = ""
        CLGeocoder().reverseGeocodeLocation(coords) { (placemark, error) in
                if error != nil {
                    
                    print("Hay un error")
                    
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
                        
                        self.updateMapBasedOnCurrentLocation(currLocAdd: adressString)
                        
                        
                    }
                    
                }
            }
            
        }
    
}

