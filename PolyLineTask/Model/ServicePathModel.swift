//
//  ServicePathModel.swift
//  Task
//
//  Created by VenkatesuSavrala on 08/07/18.
//  Copyright © 2018 bhimart. All rights reserved.
//

import Foundation
import GoogleMaps
import GoogleMaps
class SessionManager {
    func requestDirections(from start: CLLocationCoordinate2D, to end:CLLocationCoordinate2D,completionHandler: @escaping ((_ response: GMSPath?, _ error: Error?) -> Void)) {
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(start.latitude),\(start.longitude)&destination=\(end.latitude),\(end.longitude)&mode=driving") else {
            let error = NSError(domain: "LocalDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create object URL"])
            print("Error: \(error)")
            completionHandler(nil, error)
            return
        }
        // Set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: url) { (data, response, error) in
            // Check if there is an error.
            guard error == nil else {
                DispatchQueue.main.async {
                    print("Google Directions Request Error: \((error!)).")
                    completionHandler(nil, error)
                }
                return
            }
            // Make sure data was received.
            guard let data = data else {
                DispatchQueue.main.async {
                    let error = NSError(domain: "GoogleDirectionsRequest", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to receive data"])
                    print("Error: \(error).")
                    completionHandler(nil, error)
                }
                return
            }
            do{
                // Convert data to dictionary.
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    DispatchQueue.main.async {
                        let error = NSError(domain: "GoogleDirectionsRequest", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to convert JSON to Dictionary"])
                        print("Error: \(error).")
                        completionHandler(nil, error)
                    }
                    return
                }
                // Check if the the Google Direction API returned a status OK response.
                guard let status: String = json["status"] as? String, status == "OK" else {
                    DispatchQueue.main.async {
                        let error = NSError(domain: "GoogleDirectionsRequest", code: 3, userInfo: [NSLocalizedDescriptionKey: "Google Direction API did not return status OK"])
                        print("Error: \(error).")
                        completionHandler(nil, error)
                    }
                    return
                }
                if let routes: [Any] = json["routes"] as? [Any], routes.count > 0, let routes0: [String: Any] = routes[0] as? [String: Any] {
                    if let overviewPolyline = routes0["overview_polyline"] as? [String : Any] {
                        if let points = overviewPolyline["points"] as? String{
                            if let path: GMSPath = GMSPath(fromEncodedPath: points) {
                                DispatchQueue.main.async {
                                    completionHandler(path, nil)
                                }
                            }
                        }
                        return
                    } else {
                        DispatchQueue.main.async {
                            let error = NSError(domain: "GoogleDirections", code: 5, userInfo: [NSLocalizedDescriptionKey: "Failed to create GMSPath from encoded points string."])
                            completionHandler(nil, error)
                        }
                        return
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        let error = NSError(domain: "GoogleDirections", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to parse overview polyline's points"])
                        completionHandler(nil, error)
                    }
                    return
                }
                
                
            } catch let error as NSError  {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            
        }
        
        task.resume()
    }
}
