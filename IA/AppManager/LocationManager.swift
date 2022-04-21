//
//  LocationManager.swift
//  Lawwa
//
//  Created by Yogesh Raj on 26/12/19.
//  Copyright © 2019 Yogesh Raj. All rights reserved.
//

import Foundation
import CoreLocation

var address = userCurrentAddress()

protocol LocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error?)
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: CLLocation)
}


final class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationManager()
    public var delegate: LocationManagerDelegate?
    private let locationManager = CLLocationManager()
    
    public var currentLocation: CLLocationCoordinate2D? {
        return self.locationManager.location?.coordinate
    }
    
    private override init() {
        super.init()
    }
    
    private enum Status {
        case accepted
        case rejected
    }
    
    private var locationAuthorizationStatus: Status {
        return (CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() ==  .authorizedAlways) ? .accepted : .rejected
    }
    
    
    
    deinit {
        locationManager.stopUpdatingLocation()
    }
    
    public func start(){
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.pausesLocationUpdatesAutomatically = false
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    public func stop() {
        locationManager.stopUpdatingLocation()
    }
    

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //let location = locationManager.location?.coordinate
        //locations.last!
     //   print("didUpdateLocations")
        guard let location = locations.last else{ return }
        delegate?.locationManager(manager, didUpdateLocations: location)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
            
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            break
            
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            break
            
        case .restricted, .denied:
            self.delegate?.locationManager(manager, didFailWithError: nil)
            break
        default:
            break
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard self.locationAuthorizationStatus == .rejected else{ return }
        self.delegate?.locationManager(manager, didFailWithError: error)
    }

}


// MARK: - Current Address
struct userCurrentAddress {
    
    var userAddress: String?
    var userLocality: String?
    var latitude: Double?
    var longitude: Double?
    var addressType : String?
}


