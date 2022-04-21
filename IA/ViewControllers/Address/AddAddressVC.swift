//
//  AddAddressVC.swift
//  IA
//
//  Created by Yogesh Raj on 18/09/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces


class Place: NSObject {
    public private(set) var name : String
    
    public private(set) var place_Id : String
    
    init(_ placeName: String, id: String) {
        self.name = placeName
        self.place_Id = id
    }
}

class AddAddressVC: BaseClassVC {
    
    @IBOutlet weak var houseTxt: BindingTextField!
    @IBOutlet weak var pinTxt: BindingTextField!
    @IBOutlet weak var addressTxt: UITextView!
    @IBOutlet weak var homeBtn: UIButton!
    @IBOutlet weak var workBtn: UIButton!
    @IBOutlet weak var otherBtn: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var searchTxtView: UIView!
    
    var tableViewHeightConstraint: NSLayoutConstraint?
    var data: [Place] = []
    
    var timer: Timer?
    var addressType = "Home"
    let placesClient = GMSPlacesClient.shared()
    var addressArray: [AddressDataModel]?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
    }
    
    // MARK: - setupUI
    
    func setupUI() {
        self.headerTitle.text = "Select Address"
        self.backBtn.isHidden = false
        
        self.txtSearch.addTarget(self, action: #selector(self.onTextFieldDidChange), for: .editingChanged)
        self.txtSearch.LeftView(of: nil)
        self.view.bringSubviewToFront(searchTxtView)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.selectAddressType(homeBtn)
        self.mapView.isMyLocationEnabled = true
        
        address.latitude = LocationManager.shared.currentLocation?.latitude
        address.longitude = LocationManager.shared.currentLocation?.longitude
        let location:CLLocationCoordinate2D = LocationManager.shared.currentLocation ??
            CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        self.cameraMoveToLocation(toLocation: location)
        
    }
    
    func cameraMoveToLocation(toLocation: CLLocationCoordinate2D?) {
        guard let location = toLocation else{ return }
        let cameraPosition = GMSCameraPosition.camera(withTarget: location, zoom: 15.0)
        self.mapView.animate(to: cameraPosition)
    }
    
    
    @IBAction func selectAddressType(_ sender: UIButton) {
        self.homeBtn.isSelected = false
        self.workBtn.isSelected = false
        self.otherBtn.isSelected = false
        self.homeBtn.backgroundColor = .white
        self.workBtn.backgroundColor = .white
        self.otherBtn.backgroundColor = .white
        sender.isSelected = true
        
        if sender.titleLabel?.text == "Home" {
            addressType = "Home"
        } else if sender.titleLabel?.text == "Work" {
            addressType = "Work"
        } else {
            addressType = "Other"
        }
        sender.backgroundColor = UIColor.appDarkGreen
    }
    
    
    @objc func onTextFieldDidChange(){
        guard let keyword = self.txtSearch.text?.trim,
              keyword.count != 0 else{
            self.timer?.invalidate()
            self.data.removeAll()
            self.setupTableView(for: false)
            return
        }
        
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.findPlace(_:)), userInfo: ["keyword":keyword], repeats: false)
    }
    
    @objc func findPlace(_ sender: Timer){
        
        guard let userInfo = sender.userInfo as? [String:String],
              let keyword = userInfo["keyword"] else{
            return
        }
        
        placesClient.findAutocompletePredictions(fromQuery: keyword, filter: nil, sessionToken: nil) { (results, err) in
            
            guard err == nil ,let resultsDict = results, resultsDict.count != 0 else {
                self.data.removeAll()
                self.setupTableView(for: false)
                print(err?.localizedDescription as Any)
                return }
            self.data = resultsDict.map{ Place($0.attributedFullText.string, id: $0.placeID)}
            self.setupTableView(for: true)
        }
        
    }
    
    lazy var shadowView: UIView = {
        let _shadowView = UIView()
        _shadowView.translatesAutoresizingMaskIntoConstraints = false
        _shadowView.layer.shadowOffset = CGSize(width: 0.4, height: 0.4)
        _shadowView.layer.shadowColor = UIColor.darkGray.cgColor
        _shadowView.layer.shadowRadius = 4.0
        _shadowView.layer.shadowOpacity = 0.7
        return _shadowView
    }()
    
    
    lazy var tableView: UITableView = {
        let _tableView = UITableView()
        _tableView.dataSource = self
        _tableView.delegate = self
        _tableView.translatesAutoresizingMaskIntoConstraints = false
        _tableView.layer.cornerRadius = 4.0
        _tableView.layer.masksToBounds = true
        _tableView.layer.borderColor = UIColor.systemGroupedBackground.cgColor
        _tableView.layer.borderWidth = 1.0
        return _tableView
    }()
    
    func setupTableView(for state: Bool){
        
        guard state else{
            if let heightCons = self.tableViewHeightConstraint{
                self.shadowView.removeConstraint(heightCons)
            }
            self.shadowView.removeFromSuperview()
            return
        }
        
        let maxHeight = CGFloat(46.0*5)
        let height = CGFloat(self.data.count)*46.0
        
        if !self.view.subviews.contains(shadowView) {
            self.view.addSubview(shadowView)
            self.shadowView.addSubview(tableView)
            
            tableView.leadingAnchor.constraint(equalTo: self.shadowView.leadingAnchor, constant: 0.0).isActive = true
            tableView.trailingAnchor.constraint(equalTo: self.shadowView.trailingAnchor, constant: 0.0).isActive = true
            tableView.topAnchor.constraint(equalTo: self.shadowView.topAnchor, constant: 0.0).isActive = true
            tableView.bottomAnchor.constraint(equalTo: self.shadowView.bottomAnchor, constant: 0.0).isActive = true
            
            shadowView.leadingAnchor.constraint(equalTo: self.searchTxtView.leadingAnchor, constant: 8.0).isActive = true
            shadowView.trailingAnchor.constraint(equalTo: self.searchTxtView.trailingAnchor, constant: -8.0).isActive = true
            shadowView.topAnchor.constraint(equalTo: self.searchTxtView.bottomAnchor, constant: 2.0).isActive = true
            self.tableViewHeightConstraint = shadowView.heightAnchor.constraint(equalToConstant: 0.0)
            self.tableViewHeightConstraint?.constant = height > maxHeight ? maxHeight : height
            self.tableViewHeightConstraint?.isActive = true
        }else{
            self.tableViewHeightConstraint?.constant = height > maxHeight ? maxHeight : height
        }
        self.tableView.reloadData()
    }
    
    
    func performGoogleSearch(for location: CLLocationCoordinate2D) {
        
        let lat = location.latitude
        let long = location.longitude
        let locationStr = "\(lat),\(long)"
        
        var components = URLComponents(string: "https://maps.googleapis.com/maps/api/geocode/json")!
        let key = URLQueryItem(name: "key", value: "AIzaSyC4MhJYysKpRFHe9Re--y5S0_PCtxGir9Q") // use your key
        let addresss = URLQueryItem(name: "latlng", value: locationStr)
        components.queryItems = [key, addresss]
        //        print(components.url?.absoluteURL)
        let task = URLSession.shared.dataTask(with: components.url!) { data, response, error in
            guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, error == nil else {
                //print(String(describing: response))
                //print(String(describing: error))
                return
            }
            
            guard let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else {
                return
            }
            
            guard let results = json["results"] as? [[String: Any]],
                  let status = json["status"] as? String,
                  status == "OK" else {
                //print("no results")
                //print(String(describing: json))
                return
            }
            let addressStr = results.first?["formatted_address"] as? String ?? ""
            
            DispatchQueue.main.async {
                self.addressTxt.text = addressStr
                address.userAddress = addressStr
                address.latitude = lat
                address.longitude = long
            }
        }
        
        task.resume()
    }
    
    
    @objc func findLocationAddress(_ sender: Timer){
        
        guard let userInfo = sender.userInfo as? [String:CLLocationCoordinate2D],
              let location = userInfo["location"] else{
            return
        }
        
        self.performGoogleSearch(for: location)
    }
    
    
    // MARK: - Add Address Action
    @IBAction func saveAddressBtn(_ sender: UIButton) {
        guard !(houseTxt.text?.isEmpty ?? false) else {
           // AppManager.showAlert(Constants.KAppName, "Please enter house no./building/street & landmark", view: self)
            houseTxt.showError(message: "Please enter house no./building/street & landmark")
            return
        }
        
        guard !(pinTxt.text?.isEmpty ?? false) else {
         //   AppManager.showAlert(Constants.KAppName, "Please enter pincode or zipcode", view: self)
            pinTxt.showError(message: "Please enter pincode or zipcode")
            return
        }
        
        guard (pinTxt.text?.count ?? 0) > 5 else {
         //   AppManager.showAlert(Constants.KAppName, "Pincode can be from 6 to 10 digits only", view: self)
            pinTxt.showError(message: "Pincode can be from 6 to 10 digits only")
            return
        }
        
        if address.latitude != nil {
            self.addAddressAPI()
        }
    }
    
    
    // MARK: - Add Address API
    func addAddressAPI() {
        
        AppManager.startActivityIndicator()
        let param = ["name" : Constants.kAppDelegate.user?.username ?? "",
                     "location_name": "",
                     "mobile":Constants.kAppDelegate.user?.phone ?? "",
                     "floor": self.houseTxt.text ?? "",
                     "building":"",
                     "address_type": addressType,
                     "flat":"",
                     "landmark":"",
                     "full_address": "\(self.houseTxt.text ?? "")" + " \(self.addressTxt.text ?? "")" ,
                     "latitude":address.latitude ?? 0,
                     "longitude":address.longitude ?? 0,
                     "zip_code" : pinTxt.text ?? "",
                     "way":"",
                     "default_address" : addressArray?.count == 0 ? 1 : 0
        ] as [String : Any]
        ApiClient.init().apiCallMethod(URLMethods.addAddress, method: .post, parameter: param, successClosure: { (response) in
            
            AppManager.stopActivityIndicator()
            AppManager.showToast(response!["message"] as! String)
            self.navigationController?.popViewController(animated: true)
            
        }) { (msg) in
            AppManager.stopActivityIndicator()
            AppManager.showToast(msg ?? "")
        }
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension AddAddressVC:  GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture{
            //            self.isMapDrag = true
        }
    }
    
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        //        guard self.isMapDrag else{ return }
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(self.findLocationAddress(_:)), userInfo: ["location":position.target], repeats: false)
        //        self.isMapDrag = false
    }
    
    /*  @objc func findLocationAddress(_ sender: Timer){
     
     guard let userInfo = sender.userInfo as? [String:CLLocationCoordinate2D],
     let location = userInfo["location"] else{
     return
     }
     self.setLocation(location)
     
     }*/
    
    fileprivate func setLocation(_ currentLocations: CLLocationCoordinate2D) {
        let lat = currentLocations.latitude
        let long = currentLocations.longitude
        address.latitude = lat
        address.longitude = long
        AppManager.getAddressFromLatLon(pdblLatitude:currentLocations.latitude, withLongitude:currentLocations.longitude) { (addresss) in
            self.addressTxt.text =  addresss?.userAddress ?? ""
            address.userAddress = addresss?.userAddress ?? ""
        }
    }
    
}


extension AddAddressVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "autocompleteCellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil{
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        cell?.textLabel?.text = self.data[indexPath.row].name
        cell?.textLabel?.font = UIFont(name: "Linotte-Regular", size: 14.0)
        cell?.textLabel?.textColor = UIColor.darkGray
        cell?.textLabel?.numberOfLines = 0
        cell?.contentView.gestureRecognizers = nil
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)){
            cell.separatorInset = UIEdgeInsets.zero
        }
        if cell.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins)){
            cell.preservesSuperviewLayoutMargins = false
        }
        if cell.responds(to: #selector(setter: UIView.layoutMargins)){
            cell.layoutMargins = UIEdgeInsets.zero
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlace = self.data[indexPath.row]
        
        GMSPlacesClient().lookUpPlaceID(selectedPlace.place_Id) { (gmsPlace, err) in
            guard err == nil, let gmsPlace = gmsPlace else{ return }
            self.data.removeAll()
            self.setupTableView(for: false)
            self.txtSearch.text = gmsPlace.formattedAddress
            
            let camera = GMSCameraPosition.camera(withLatitude: (gmsPlace.coordinate.latitude),
                                                  longitude: (gmsPlace.coordinate.longitude),
                                                  zoom: 15.0)
            self.mapView.animate(to: camera)
            self.txtSearch.resignFirstResponder()
            
        }
    }
    
}
