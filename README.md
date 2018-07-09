PolyLineTask
============

[![CocoaPods](https://github.com/abhiroyal/PolyLineTask)
PolyLineTask is a Project written in Swift that makes it easy for Draw Polyline. 

- [Features](#features)
- [The Basics](#the-basics)
- [Installation](#installation)

# Features:
- GMS Map View
- Draws Polyline with different Colours from Current Location
- Different Markers For Different Locations

# The Basics

1.To get Directions for locations initialize with one or more  destinations   as shown below
```swift
var _locationsForpoly = [CLLocationCoordinate2D]()
let chennaiAirport = CLLocationCoordinate2D(latitude: 12.9832175, longitude:80.1649614)//ChennaiAirport
let mumbaiAirport = CLLocationCoordinate2D(latitude:19.0896, longitude:72.8656)//MumbaiAirport
//intialising locations
self._locationsForpoly = [chennaiAirport,mumbaiAirport]
```

2.To Different Colours For Polylines:
``` swift
var polyLinecolour :[UIColor] = [.red,.blue]
```

3.To Different icons for Destination Marker:
```swift
var markerimages = [#imageLiteral(resourceName: "RedIcon"),#imageLiteral(resourceName: "BlueIcon")]
```
4.To Draw Polyline:
```swift
DrawPolyLine(start:Startingpoints, end: Destinationpoints,colour: PolylineColour)
```
5.To Set Marker:
```swift
setMarker(lat: Marker lattitude, long: Marker longitude, image: Marker Image)
```
6. Draw PolyLine Function:

```swift
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
```


7. Set Marker Function:
```swift
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
```

8.To Convert Lat & Long To Adress string Function:
```swift
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
```
# Installation
1.Download File / Open in Xcode.

2.Do Pod install in downloaded repository.

3.Get the Token From https://developers.google.com/maps/documentation/ios-sdk/start?authuser=1 ,enabe Maps api & Directions Api.

4.Set The Token In AppDelegate.

```swift
GMSServices.provideAPIKey("Token")
GMSPlacesClient.provideAPIKey("Token")
```
