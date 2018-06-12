//
//  GMapViewController.swift
//  codingTask
//
//  Created by Parimala Ranganath Velayudam on 11/06/18.
//  Copyright © 2018 VPR productions. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON


class GMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    var locationManager = CLLocationManager()
    var currentLocation = LocationDataModel()
    var cAirLocation    = LocationDataModel()
    var mAirLocation    = LocationDataModel()
    var gmapKey:String  = "AIzaSyBmTMDB1NY0nSxnulTk4bltJHljCFtKMJo"
    
    
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
    
    
    
    // MARK:  creating Map  and adding the markers
    func generateUI() {
        
        updateMapUI(zoom:6.0)
        addMarker(forLocation: currentLocation, color: UIColor(red:0.07, green:0.29, blue:0.07, alpha:1.0))
        setDesignatedLocationMarkers()
        drawPolyLines()
        
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
    
    func setDesignatedLocationMarkers() {
        
        let chAirCoord = CLLocation(latitude: 12.990797, longitude: 80.165696)
        cAirLocation.locCoords = chAirCoord
        getAddress(coords: chAirCoord) { (address:String) -> () in
            self.cAirLocation.address = address
            self.addMarker(forLocation: self.cAirLocation, color:UIColor(red:0.00, green:0.00, blue:1.00, alpha:1.0))
        }
        
        let muAirCoord = CLLocation(latitude: 19.089613, longitude: 72.865607)
        mAirLocation.locCoords = muAirCoord
        getAddress(coords: muAirCoord) { (address:String) -> () in
            self.mAirLocation.address = address
            self.addMarker(forLocation: self.mAirLocation, color: UIColor(red:1.00, green:0.00, blue:0.00, alpha:1.0))
        }
        
    }
    
    
    //MARK: Polyline implementation for 2 paths
    func drawPolyLines() {
        drawPolyLine(source:currentLocation, destination:mAirLocation, color:UIColor(red:0.89, green:0.45, blue:0.27, alpha:1.0))
        drawPolyLine(source:currentLocation, destination:cAirLocation, color:UIColor(red:0.45, green:0.40, blue:0.56, alpha:1.0))
        
    }
    
    func drawPolyLine(source: LocationDataModel, destination: LocationDataModel, color: UIColor) {
        
        let originCoords:String = "\((source.locCoords?.coordinate.latitude)!),\((source.locCoords?.coordinate.longitude)!)"
        let destCoords:String = "\((destination.locCoords?.coordinate.latitude)!),\((destination.locCoords?.coordinate.longitude)!)"
        drawPath(origin: originCoords, destination: destCoords,color: color)
    }
    
    func drawPath (origin: String, destination: String, color: UIColor) {
        
        let prefTravel:String = "walking"
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=\(prefTravel)&key=" + gmapKey)
        
        Alamofire.request(url!).responseJSON{(responseData) -> Void in
            if((responseData.result.value) != nil) {
               
                let swiftyJsonVar = JSON(responseData.result.value!)
                
                if let resData = swiftyJsonVar["routes"].arrayObject {
                    let routes = resData as! [[String: AnyObject]]
                    
                    if routes.count > 0 {
                        for rts in routes {
                           
                            let overViewPolyLine = rts["overview_polyline"]?["points"]
                            let path = GMSMutablePath(fromEncodedPath: overViewPolyLine as! String)
                            
                            let polyline = GMSPolyline.init(path: path)
                            polyline.strokeWidth = 4
                            polyline.strokeColor = color
                            polyline.map = self.mapView
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Reverse geocode to fetch the address of  location
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
                    
                    if place.name  != nil {
                        addressStr = addressStr + place.name! + ", "
                    }
                    if place.subLocality != nil {
                        addressStr = addressStr + place.subLocality! + ", "
                    }
                    
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
                    
                    //print(addressStr)
                    completion?(addressStr)
                }
                
            }
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
        let view = UIView(frame: CGRect.init(x: 0, y: 0, width: 250, height: 81))
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 10
        
        let annotationLbl = UILabel(frame: CGRect.init(x: 8, y: 8, width: view.frame.size.width - 16, height: 75))
        annotationLbl.text =  marker.snippet!
        annotationLbl.font = UIFont(name: "HelveticaNeue", size: 15)
        annotationLbl.numberOfLines = 5
        view.addSubview(annotationLbl)
        
        
        return view
    }
    
}

