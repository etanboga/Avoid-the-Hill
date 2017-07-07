//
//  ViewController.swift
//  Avoid the Hill
//
//  Created by Ege Tanboga on 7/4/17.
//  Copyright © 2017 Tanbooz. All rights reserved.
//

//Programmable web, a place to find APIs and stuff
//Postman as well


import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces
import SwiftyJSON
import Alamofire




let CHOOSEDESTINATIONRADIUS = 4
let NAVIGATORRADIUS = 10

class ViewController: UIViewController, CLLocationManagerDelegate  {
    
    //MARK: - Properties
    
    @IBOutlet weak var chooseDestinationButton: UIButton!
    @IBOutlet weak var myMapView: GMSMapView!
    
    @IBOutlet weak var navigatorButton: UIButton!
    
    
    @IBOutlet weak var myMapTopConstraint: NSLayoutConstraint!
    
    
    let manager = CLLocationManager()
    var startingLocation : CLLocationCoordinate2D? = nil
    var endingLocation : CLLocationCoordinate2D? = nil
    
    var finalPlace: GMSPlace? = nil
    
    //MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        chooseDestinationButton.layer.cornerRadius = CGFloat(CHOOSEDESTINATIONRADIUS)
        navigatorButton.layer.cornerRadius = CGFloat(NAVIGATORRADIUS)
        navigatorButton.isHidden = true
        navigatorButton.isUserInteractionEnabled = false
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest       //This part works for the phone because we have internal location services installed. It does not work on the simulator since we do not have access to the location while launching the app and then get the authorization to change our location
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        if let location = manager.location {
        let myLongitude = location.coordinate.longitude
        let myLatitude = location.coordinate.latitude
            let camera = GMSCameraPosition.camera(withLatitude: myLatitude, longitude: myLongitude, zoom: 15)
            myMapView.camera = camera
            let currentLocation = CLLocationCoordinate2DMake(myLatitude, myLongitude)
  
            
            myMapView.isMyLocationEnabled = true
            startingLocation = currentLocation
            //print("Information about starting location: \(startingLocation?.latitude ?? 0)   \( startingLocation?.longitude ?? 0)")
        }
        
        myMapView.settings.myLocationButton = true
        myMapView.settings.allowScrollGesturesDuringRotateOrZoom = true
        myMapView.settings.zoomGestures = true
        
        //End of configuration of current location
        
        //Recognizes tap gesture on the screen so you can remove keyboard
        
        let tapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location {
            let myLongitude = location.coordinate.longitude
            let myLatitude = location.coordinate.latitude
            let currentLocation = CLLocationCoordinate2DMake(myLatitude, myLongitude)
            startingLocation = currentLocation
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //this works for both cases however for the phone, the same location is set twice. Since after launching the app in simulator, we ask for authorization, this should change everything properly.
        if status == .authorizedWhenInUse {

            if let location = manager.location {
                let myLongitude = location.coordinate.longitude
                let myLatitude = location.coordinate.latitude
                let camera = GMSCameraPosition.camera(withLatitude: myLatitude, longitude: myLongitude, zoom: 10)
                myMapView.camera = camera
                let currentLocation = CLLocationCoordinate2DMake(myLatitude, myLongitude)
                myMapView.isMyLocationEnabled = true
                startingLocation = currentLocation
                //print("Information about starting location: \(startingLocation?.latitude ?? 0)   \( startingLocation?.longitude ?? 0)")
            }
            
            manager.startUpdatingLocation()
            self.myMapView.isMyLocationEnabled = true
            myMapView.settings.myLocationButton = true
            
        }
        
        if status == .denied {
            manager.requestWhenInUseAuthorization()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - IBActions
    
    @IBAction func finalDestinationButtonTapped(_ sender: UIButton) {
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self as GMSAutocompleteViewControllerDelegate
        present(autocompleteController, animated: true) {
        }
    }
    
    
    @IBAction func navigatorButtonTapped(_ sender: UIButton) {
        
        //initiating the navigation
        
        self.myMapView.clear()
        
        let calculationStartLocation = startingLocation!
        let calculationEndLocation = endingLocation!
        let origin = "\(calculationStartLocation.latitude),\(calculationStartLocation.longitude)"
        let destination = "\(calculationEndLocation.latitude),\(calculationEndLocation.longitude)"
        
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=walking&alternatives=true&key=AIzaSyD59ki59snUv-wXI8JJaZNWCsuEN4o69WE"
        
        Alamofire.request(url).responseJSON { response in
            
            let json = JSON(data: response.data!)
            //print(json)
            let routes = json["routes"].arrayValue
            
            var averageAngles = [Double] ()
            
                for index in 0..<routes.count {
                    
                    //print("for route \(index)")
                    
                    var angleValues = [Double] ()
                    var weights = [Double] ()
                    var totalDistance = 0.0
                    let legs = routes[index]["legs"]
                    for secondindex in 0..<legs.count {
                        let steps = legs[secondindex]["steps"]
                        //print(steps)
                        for thirdindex in 0..<steps.count {
                            //print("for step \(thirdindex)        ")
                            
                            let startLatitude = steps[thirdindex]["start_location"]["lat"].doubleValue
                            let startLongitude = steps[thirdindex]["start_location"]["lng"].doubleValue
                            let endLatitude = steps[thirdindex]["end_location"]["lat"].doubleValue
                            let endLongitude = steps[thirdindex]["end_location"]["lng"].doubleValue
                            let distance  = steps[thirdindex]["distance"]["value"].doubleValue
                            print(distance)
//                            print(startLatitude)
//                            print(startLongitude)
//                            print(endLatitude)
//                            print(endLongitude)
//                            print("         ")
                            let segmentStartCoordinate  = CLLocationCoordinate2DMake(startLatitude, startLongitude)
                            let segmentEndCoordinate  = CLLocationCoordinate2DMake(endLatitude, endLongitude)
                            //let elevationAngle = self.calculateAngle(segmentStart: segmentStartCoordinate, segmentEnd: segmentEndCoordinate, distance: distance)
                            
                            self.calculateAngle(segmentStart: segmentStartCoordinate, segmentEnd: segmentEndCoordinate, distance: distance, completion: { (elevationAngle) in
                                totalDistance += (distance)
                                angleValues.append(elevationAngle)
                                weights.append(distance)
                            })
                        }
                    }
                    //weights.map {$0 / totalDistance}
                    print(weights) //check if division is complete
                    let averageAngle = self.calculateAverageAngle(angles: angleValues, weights: weights)
                    averageAngles.append(averageAngle)
            }
            let minimumAngle  = averageAngles.min()
            let indexOfMinimumAngle = averageAngles.index(of: minimumAngle!)
            //now we need to draw the route at the same index
            self.drawPath(routes: routes, minIndex: indexOfMinimumAngle!)
        }

        //completing navigation formatting
        
        
        myMapView.animate(toLocation: endingLocation!)
        let marker = GMSMarker(position: endingLocation!)
        marker.title = finalPlace?.name
        marker.snippet = finalPlace?.formattedAddress
        marker.map = myMapView

    
    }
    
    //MARK: - Functions
    
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    func drawPath( routes: [JSON], minIndex: Int)
    {
        
            for index in 0..<routes.count
            {
                let routeOverviewPolyline = routes[index]["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                if index == minIndex {
                polyline.strokeWidth = 30
                } else {
                polyline.strokeWidth = 10
                }
                polyline.strokeColor = .random()
                polyline.map = self.myMapView
            }
    }
    
    func calculateAngle(segmentStart: CLLocationCoordinate2D, segmentEnd: CLLocationCoordinate2D, distance: Double, completion: @escaping (Double) -> Void) {
        
        //APIKEY AIzaSyCDnPJTbKCTuVPKJm4q_KCm0Fipz7d3Tfg
        
        let origin = "\(segmentStart.latitude),\(segmentStart.longitude)"
        let destination = "\(segmentEnd.latitude),\(segmentEnd.longitude)"
        var originElevation = 0.0
        var destinationElevation = 0.0
        let myoriginurl = "https://maps.googleapis.com/maps/api/elevation/json?locations=\(origin)&key=AIzaSyCDnPJTbKCTuVPKJm4q_KCm0Fipz7d3Tfg"
        Alamofire.request(myoriginurl).responseJSON { response in
    
            let json = JSON(data: response.data!)
            originElevation = json["results"][0]["elevation"].doubleValue
            print(originElevation)
        }
        let mydestinationurl = "https://maps.googleapis.com/maps/api/elevation/json?locations=\(destination)&key=AIzaSyCDnPJTbKCTuVPKJm4q_KCm0Fipz7d3Tfg"
        Alamofire.request(mydestinationurl).responseJSON { response in
            
            let json = JSON(data: response.data!)
            destinationElevation = json["results"][0]["elevation"].doubleValue
            print(destinationElevation)
            print("I will work")
            let elevationDifference = abs(destinationElevation-originElevation)
            let angle = acos(elevationDifference/distance)
            completion(angle)
        }
    }
    
    func calculateAverageAngle(angles: [Double], weights: [Double]) -> Double {
        var average: Double = 0
        for index in 0..<angles.count {
            average += angles[index]*weights[index]
        }
        return average
    }
    
}




extension ViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection, can add button from here
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {

        let finalDestination = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude)
        self.endingLocation = finalDestination
        
        //set location to ending location
        
        let camera = GMSCameraPosition.camera(withLatitude: (self.endingLocation?.latitude)!, longitude: (self.endingLocation?.longitude)!, zoom: 15)
        myMapView.camera = camera
        
        //put a marker to that location
        
        finalPlace = place
        
        let marker = GMSMarker(position: endingLocation!)
        marker.title = finalPlace?.name
        marker.snippet = finalPlace?.formattedAddress
        marker.map = myMapView
        
        //delete the choosedestination button
        
        //chooseDestinationButton.isHidden = true
        
       // chooseDestinationButton.isUserInteractionEnabled = false
        
        
        //show button
        
        
        navigatorButton.isUserInteractionEnabled = true
        navigatorButton.isHidden = false
        
        self.chooseDestinationButton.setTitle("Choose Another Destination", for: .normal)
        self.chooseDestinationButton.titleLabel?.adjustsFontSizeToFitWidth = true


        dismiss(animated: true, completion: nil)
        
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        

        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}

//MARK: - Helper functions



