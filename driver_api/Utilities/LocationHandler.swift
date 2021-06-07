//
//  LocationHandler.swift
//  driver_api
//
//  Created by WY on 2021/6/4.
//

import CoreLocation

class LocationHandler: NSObject, CLLocationManagerDelegate{
    
    static let shared = LocationHandler()
    var locationManager: CLLocationManager!
    var location: CLLocation?
    
    override init(){
        super.init()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
    }
}
