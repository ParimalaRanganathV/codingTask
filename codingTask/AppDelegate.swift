//
//  AppDelegate.swift
//  codingTask
//
//  Created by Parimala Ranganath Velayudam on 11/06/18.
//  Copyright © 2018 VPR productions. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        GMSServices.provideAPIKey("AIzaSyBmTMDB1NY0nSxnulTk4bltJHljCFtKMJo")
        GMSPlacesClient.provideAPIKey("AIzaSyBmTMDB1NY0nSxnulTk4bltJHljCFtKMJo")
        
        return true
    }



}

