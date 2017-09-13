//
//  CLLocationManager+Extension.swift
//  
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import CoreLocation


extension CLLocationManager {
    
    static func initializeLocationManager(delegate: CLLocationManagerDelegate) -> CLLocationManager {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = delegate
        return manager
    }
    
    static func showLocationPermissionAlert(vc: UIViewController) {
        
        switch CLLocationManager.authorizationStatus() {
            
        case .restricted, .denied, .notDetermined:
            let alertController = UIAlertController(
                title: "Turn On Location Services",
                message: "1. Tap Settings\n2. Tap Location\n 3. Tap 'While Using the App'",
                preferredStyle: .alert)
            
            let notNowAction = UIAlertAction(title: "Not Now",
                                             style: .cancel,
                                             handler: nil)
            
            let openSettingAction = UIAlertAction(title: "Settings", style: .default) { (action) in
                if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.openURL(url as URL)
                }
            }
            
            alertController.addAction(notNowAction)
            alertController.addAction(openSettingAction)
            vc.present(alertController, animated: true, completion: nil)
        default:
            break
        }
    }
    
    func requestMyLocation() {
        if #available(iOS 9.0, *) {
            self.requestLocation()
        } else {
            self.startUpdatingLocation()
        }
    }
    
    func stopMyLocationRequest() {
        self.stopUpdatingLocation()
    }
}
