//
//  GMapViewController.swift
//  codingTask
//
//  Created by Parimala Ranganath Velayudam on 11/06/18.
//  Copyright © 2018 VPR productions. All rights reserved.
//

import UIKit
import GoogleMaps


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
        
        mapView.isHidden = true
    }
    
    
    func updateMapUI(zoom: Float) {
        mapView.isHidden = false
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
    
    
    //Reverse geocode to fetch the address of  location
    func getAddress(coords: CLLocation, completion: ((String) -> Void )?) {
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
        setDesignatedLocationMarkers()
        drawPolyLines()

    }
    
    func setDesignatedLocationMarkers() {
        
        let chAirCoord = CLLocation(latitude: 12.9822222222, longitude: 80.1636111111)
        cAirLocation.locCoords = chAirCoord
        getAddress(coords: chAirCoord) { (address:String) -> () in
            self.cAirLocation.address = address
            self.addMarker(forLocation: self.cAirLocation, color: .blue)
        }
        
        let muAirCoord = CLLocation(latitude: 19.0886111111, longitude: 72.8683333333)
        mAirLocation.locCoords = muAirCoord
        getAddress(coords: muAirCoord) { (address:String) -> () in
            self.mAirLocation.address = address
            self.addMarker(forLocation: self.mAirLocation, color: .red)
        }
        
    }
    
    func drawPolyLines() {
        drawPolyLine(source:currentLocation, destination:mAirLocation, color:UIColor.blue)
        drawPolyLine(source:currentLocation, destination:cAirLocation, color:UIColor.darkGray)
        
    }
    
    func drawPolyLine(source: LocationDataModel, destination: LocationDataModel, color: UIColor) {
        let path = GMSMutablePath()
        path.add(CLLocationCoordinate2D(latitude: (source.locCoords?.coordinate.latitude)! , longitude: (source.locCoords?.coordinate.longitude)!))
        path.add(CLLocationCoordinate2D(latitude: (destination.locCoords?.coordinate.latitude)! , longitude: (destination.locCoords?.coordinate.longitude)!))
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 3
        polyline.strokeColor = color
        polyline.geodesic = true
        polyline.map = mapView
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
        view.layer.cornerRadius = 10
        
        let annotationLbl = UILabel(frame: CGRect.init(x: 8, y: 8, width: view.frame.size.width - 16, height: 60))
        annotationLbl.text =  marker.snippet!
        annotationLbl.font = UIFont(name: "HelveticaNeue", size: 15)
        annotationLbl.numberOfLines = 3
        view.addSubview(annotationLbl)
        
        
        return view
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

