//
//  OrderTrackMapVC.swift
//  Clever
//
//  Created by admin on 02/01/20.
//  Copyright © 2020 Admin octal. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase
import FirebaseDatabase

class OrderTrackMapVC: BaseClassVC, GMSMapViewDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var btnReCenter: GradientButton!
    
    var orderDetail : OrderDetailModel?
    var bounds = GMSCoordinateBounds()
    private var courierLocationMarker: GMSMarker?
    var previousLocation: CLLocationCoordinate2D!
    var isUserFirtLocation = false
    var carAnimator: CarAnimator!
    private var isUpdate = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.isMyLocationEnabled = false
        mapView.delegate = self
        setupUI()
        
        if #available(iOS 11.0, *) {
            mapView.padding = UIEdgeInsets(top: self.view.safeAreaInsets.bottom, left: 0, bottom: 0, right: 0)
        }
        guard let deliveryAddres = orderDetail?.deliveryAddress?.addressLocation else {
            return
        }
        let lat = deliveryAddres.coordinates?.last ?? 0.0
        let long = deliveryAddres.coordinates?.first ?? 0.0
        
        let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double.convertToDouble(anyValue: lat), longitude: Double.convertToDouble(anyValue: long))
        let currentLocationMarker = GMSMarker(position: location)
        currentLocationMarker.icon = UIImage(named: "home-location")
        currentLocationMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        currentLocationMarker.map = self.mapView
        self.bounds = self.bounds.includingCoordinate(location)
        
        self.cameraMoveToLocation(toLocation: location)
    }
    
    func setupUI() {
        
        self.headerTitle.text = "Track Order"
        self.menuBtn.isHidden = true
        self.backBtn.isHidden = false
        
        NotificationCenter.default.addObserver(forName: Notification.Name("NotificationOrderUpdate"), object: nil, queue: nil) { (notification) in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getCourierLatLong()
    }
    
    func cameraMoveToLocation(toLocation: CLLocationCoordinate2D?) {
        guard let location = toLocation else{ return }
        let cameraPosition = GMSCameraPosition.camera(withTarget: location, zoom: 17.0)
        self.mapView.animate(to: cameraPosition)
    }
    
    func getCourierLatLong() {
        
        let driver = orderDetail?.driver?.first
        let ref = Database.database().reference()
        ref.child("athwas_drivers").child("\(driver?.id ?? "")").observe(.value) { (snapshot) in
            if !snapshot.exists() { return }
            let courierLocation = snapshot.value as! NSDictionary
            let lat = courierLocation["lat"] as? Double
            let lng = courierLocation["lng"] as? Double
            let location: CLLocationCoordinate2D =  CLLocationCoordinate2D(
                latitude: lat ?? 26.911953,
                longitude: lng ?? 75.775497)
            if !self.isUserFirtLocation {
                self.previousLocation = location
                self.isUserFirtLocation = true
            }
            self.fetchCourierLocation(courierLocation: location)
        }
    }
    
    func fetchCourierLocation(courierLocation: CLLocationCoordinate2D) {
        
        if courierLocationMarker == nil {
            
            courierLocationMarker = GMSMarker(position: courierLocation)
            courierLocationMarker?.icon = UIImage(named: "start_location")
            courierLocationMarker?.setIconSize(scaledToSize: .init(width: 30, height: 70))
            courierLocationMarker?.map = mapView
            
            carAnimator = CarAnimator(carMarker: courierLocationMarker!, mapView: mapView)
            self.bounds = self.bounds.includingCoordinate(courierLocation)
            if isUpdate {
                let update = GMSCameraUpdate.fit(self.bounds, withPadding: 60)
                self.mapView.animate(with: update)
                isUpdate = false
            }
            
        } else {
            carAnimator.animate(from: previousLocation, to: courierLocation)
        }
        previousLocation = courierLocation
    }
    
    @IBAction func btnReCenterTap(_ sender: Any) {
        let update = GMSCameraUpdate.fit(self.bounds, withPadding: 60)
        self.mapView.animate(with: update)
        btnReCenter.isHidden = true
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture {
            btnReCenter.isHidden = false
        }
    }

}

extension GMSMarker {
    func setIconSize(scaledToSize newSize: CGSize) {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        icon?.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        icon = newImage
    }
}
