//
//  ViewController.swift
//  Task
//
//  Created by VenkatesuSavarala on 08/07/18.
//  Copyright © 2018 bhimart. All rights reserved.
//

import UIKit
import GoogleMaps
class ViewController: UIViewController {
    let locationManager = CLLocationManager()
    @IBOutlet  var map_View: GMSMapView!
    var userLocation = CLLocationCoordinate2D()
    var _locationsForpoly = [CLLocationCoordinate2D]()
    var polyLinecolour :[UIColor] = [.red,.blue]
    var markerimages = [#imageLiteral(resourceName: "RedIcon"),#imageLiteral(resourceName: "BlueIcon")]
    override func viewDidLoad() {
        super.viewDidLoad()
        let chennaiAirport = CLLocationCoordinate2D(latitude: 12.9832175, longitude:80.1649614)//ChennaiAirport
        let mumbaiAirport = CLLocationCoordinate2D(latitude:19.0896, longitude:72.8656)//MumbaiAirport
        //intialising locations
        self._locationsForpoly = [chennaiAirport,mumbaiAirport]
        
        self.locationManager.requestAlwaysAuthorization()
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    func setupView()  {
        self.map_View.clear() 
        for  i in 0..<self._locationsForpoly.count {
            //DrawingPolyLine
            self.DrawPolyLine(start: self.userLocation, end: self._locationsForpoly[i],colour: self.polyLinecolour[i])
            self.setMarker(lat: self._locationsForpoly[i].latitude, long: self._locationsForpoly[i].longitude, image: self.markerimages[i])
        }
        self.setMarker(lat: self.userLocation.latitude, long: self.userLocation.longitude, image: #imageLiteral(resourceName: "GreenIcon"))
        //Your map initiation code
        self.map_View.delegate = self
        self.map_View?.isMyLocationEnabled = true
        self.map_View.settings.myLocationButton = true
        self.map_View.settings.compassButton = true
        self.map_View.settings.zoomGestures = true
    }
    //SetupformarkerView
    func setMarker(lat: CLLocationDegrees,long:CLLocationDegrees ,image:UIImage) {
        // I have taken a pin image which is a custom image
        let markerImage = image
        //creating a marker view
        let markerView = UIImageView(image: markerImage)
        //changing the tint color of the image
        markerView.tintColor = UIColor.red
        let position = CLLocationCoordinate2DMake(lat,long)
        let marker = GMSMarker(position: position)
        marker.iconView = markerView
        self.getAddressFromLatLon(lat, long) { (address) in
            marker.title = address
        }
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude:long, zoom: 6.0)
        self.map_View.camera = camera
        marker.map = self.map_View
    }
    //Setupp for polyline
    func DrawPolyLine(start: CLLocationCoordinate2D,end:CLLocationCoordinate2D ,colour: UIColor = .blue) {
        let sessionManager = SessionManager()
        sessionManager.requestDirections(from: start, to: end, completionHandler: { (path, error) in
            if let error = error {
                print("Something went wrong, abort drawing!\nError: \(error)")
            } else {
                let polyline = GMSPolyline(path: path!)
                // Add the GMSPolyline object to the mapView
                polyline.strokeColor = colour
                polyline.strokeWidth = 2.0
                polyline.map = self.map_View
                // Move the camera to the polyline
                let bounds = GMSCoordinateBounds(path: path!)
                let cameraUpdate = GMSCameraUpdate.fit(bounds, with: UIEdgeInsets(top: 40, left: 15, bottom: 10, right: 15))
                self.map_View.animate(with: cameraUpdate)
            }
        })
    }
    //Get Address From Lat & long
    func getAddressFromLatLon(_ pdblLatitude: CLLocationDegrees,_ pdblLongitude: CLLocationDegrees,completionHandler: @escaping ((_ address: String?) -> Void)) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = Double("\(pdblLatitude)")!
        let lon: Double = Double("\(pdblLongitude)")!
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        var addressString : String = ""
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                else{
                    let pm = placemarks! as [CLPlacemark]
                    if pm.count > 0 {
                        let pm = placemarks![0]
                        if pm.name != nil {
                            addressString = addressString + pm.name! + ","
                        }
                        if pm.subLocality != nil {
                            addressString = addressString + pm.subLocality! + ","
                        }
                        if pm.administrativeArea != nil {
                            addressString = addressString + pm.administrativeArea! + ","
                        }
                        if pm.country != nil {
                            addressString = addressString + pm.country!
                        }
                        print(addressString)
                        completionHandler(addressString)
                    }
                }
        })
    }
    
}
extension ViewController : GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        map_View.isMyLocationEnabled = true
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        map_View.isMyLocationEnabled = true
        
        if (gesture) {
            mapView.selectedMarker = nil
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        map_View.isMyLocationEnabled = true
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("COORDINATE \(coordinate)") // when you tapped coordinate
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        map_View.isMyLocationEnabled = true
        map_View.selectedMarker = nil
        return false
    }
    
}
//LocationManager Delegate
extension ViewController : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        locationManager.stopUpdatingLocation()
        self.userLocation = CLLocationCoordinate2DMake(locValue.latitude, locValue.longitude)
        self.setupView()
    }
}
