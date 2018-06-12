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
    var cAirLocation    = LocationDataModel()
    var mAirLocation    = LocationDataModel()
   
 
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        mapView.delegate = self
    }
    
    
    func updateMapUI(zoom: Float) {
        let latitude = currentLocation.locCoords?.coordinate.latitude
        let longitude = currentLocation.locCoords?.coordinate.longitude
        let camera = GMSCameraPosition.camera(withLatitude: latitude!, longitude: longitude!, zoom: zoom)
        mapView.camera = camera
    }
    
    func addMarker(forLocation markerLocation: LocationDataModel, color: UIColor) {
        let latitude = markerLocation.locCoords?.coordinate.latitude
        let longitude = markerLocation.locCoords?.coordinate.longitude
        let marker = GMSMarker()
        marker.icon = GMSMarker.markerImage(with: color)
        marker.snippet = markerLocation.address
        marker.position = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        marker.map = mapView
    }
    
    //Reverse geocode to fetch the address of current location
    func getAddress(coords: CLLocation, completion: ((String) -> Void )?) {
        //var isAddrGenerated:Bool = false
        var addressStr : String = ""
        CLGeocoder().reverseGeocodeLocation(coords) {
            (placemark, error) in
            if error != nil {
                print("Reverse geocode error")
            } else {
                let place = placemark! as [CLPlacemark]
                
                if place.count > 0 {
                    let place = placemark![0]
                    
                    if place.thoroughfare != nil {
                        addressStr = addressStr + place.thoroughfare! + ", "
                    }
                    if place.subThoroughfare != nil {
                        addressStr = addressStr + place.subThoroughfare! + "\n"
                    }
                    if place.locality != nil {
                        addressStr = addressStr + place.locality! + " - "
                    }
                    if place.postalCode != nil {
                        addressStr = addressStr + place.postalCode! + "\n"
                    }
                    if place.subAdministrativeArea != nil {
                        addressStr = addressStr + place.subAdministrativeArea! + " - "
                    }
                    if place.country != nil {
                        addressStr = addressStr + place.country!
                    }
                    
                    print(addressStr)
                    completion?(addressStr)
                }
                
            }
        }
        
       
        
    }
    
    func generateUI() {
        updateMapUI(zoom:6.0)
        addMarker(forLocation: currentLocation, color: UIColor(displayP3Red: 0.33, green: 1.00, blue: 0.10, alpha: 1.0))
        setDesignatedLocations()

    }
    
    func setDesignatedLocations() {
        
        let chAirCoord = CLLocation(latitude: 12.9814, longitude: 80.1641)
            cAirLocation.locCoords = chAirCoord
        getAddress(coords: chAirCoord) { (address:String) -> () in
            self.cAirLocation.address = address
            self.addMarker(forLocation: self.cAirLocation, color: .blue)
        }
        
        let muAirCoord = CLLocation(latitude: 19.097403, longitude: 72.874245)
            mAirLocation.locCoords = muAirCoord
        getAddress(coords: muAirCoord) { (address:String) -> () in
            self.mAirLocation.address = address
            self.addMarker(forLocation: self.mAirLocation, color: .red)
        }
        
        
    }
    
}


// MARK: Location manager delegate methods - capturing current location
extension GMapViewController: CLLocationManagerDelegate {
    
    // incoming  events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location :CLLocation? = locations.last
        let uLocation: CLLocation = location!
        if uLocation.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            currentLocation.locCoords = location
           
            }
        
        getAddress(coords: currentLocation.locCoords!) {
            (address:String) -> () in
            self.currentLocation.address = address
            self.generateUI()
            
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

// MARK: MapView delegate methods - customizing the info view to our need

extension GMapViewController: GMSMapViewDelegate {
    /* handles Info Window tap */
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("didTapInfoWindowOf")
    }
    
    /* handles Info Window long press */
    func mapView(_ mapView: GMSMapView, didLongPressInfoWindowOf marker: GMSMarker) {
        print("didLongPressInfoWindowOf")
    }
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let view = UIView(frame: CGRect.init(x: 0, y: 0, width: 200, height: 70))
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 6
        
        let lbl1 = UILabel(frame: CGRect.init(x: 8, y: 8, width: view.frame.size.width - 16, height: 60))
        lbl1.text =  marker.snippet!
        lbl1.font = UIFont(name: "HelveticaNeue", size: 15)
        lbl1.numberOfLines = 3
        view.addSubview(lbl1)
        
        
        return view
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

