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
    var routesLoopCallCounter = 0
    let activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    //MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initial setup for layout
        
        chooseDestinationButton.layer.cornerRadius = CGFloat(CHOOSEDESTINATIONRADIUS)
        navigatorButton.layer.cornerRadius = CGFloat(NAVIGATORRADIUS)
        navigatorButton.isHidden = true
        navigatorButton.isUserInteractionEnabled = false
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest       //This part works for the phone because we have internal location services installed. It does not work on the simulator since we do not have access to the location while launching the app and then get the authorization to change our location
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        //get current location and show that location on the map
        
        if let location = manager.location {
            let myLongitude = location.coordinate.longitude
            let myLatitude = location.coordinate.latitude
            let camera = GMSCameraPosition.camera(withLatitude: myLatitude, longitude: myLongitude, zoom: 15)
            myMapView.camera = camera
            let currentLocation = CLLocationCoordinate2DMake(myLatitude, myLongitude)
            
            
            myMapView.isMyLocationEnabled = true
            startingLocation = currentLocation
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
        //if our current destination changes after we start the application, updates the current location
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
    
    @IBAction func finalDestinationButtonTapped(_ sender: UIButton) {   //leads to search bar
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self as GMSAutocompleteViewControllerDelegate
        present(autocompleteController, animated: true) {
        }
    }
    
    
    @IBAction func navigatorButtonTapped(_ sender: UIButton) {
        
        //initiating the navigation
        
        self.myMapView.clear()
        
        //gets starting and ending location for navigation
        
        let calculationStartLocation = startingLocation!
        let calculationEndLocation = endingLocation!
        let origin = "\(calculationStartLocation.latitude),\(calculationStartLocation.longitude)"
        let destination = "\(calculationEndLocation.latitude),\(calculationEndLocation.longitude)"
        
        
        //setup activity indicator to show the view is loading
        
        setupActivityIndicator()
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=walking&alternatives=true&key=AIzaSyD59ki59snUv-wXI8JJaZNWCsuEN4o69WE"
        
        Alamofire.request(url).responseJSON { response in
            
            let json = JSON(data: response.data!)
            
            //gets different routes between current location and final destination
            
            let routes = json["routes"].arrayValue
            
            if routes.count == 0 {
                self.activityIndicator.stopAnimating()
                self.giveAlert(title: "Invalid Destination", message: "You cannot walk to specified destination", actionTitle: "Choose Another Destination")
            }
            
            var averageAngles = [Double] () //to store average angles corresponding to each route
            
            for index in 0..<routes.count {     //for each route given
                
                var angleValues = [Double] ()   //records angle values of steps
                var weights = [Double] ()       //records weights of steps for weighted average
                var totalDistance = 0.0
                let legs = routes[index]["legs"]    //get different legs for the route
                var callCounter = 0
                
                for secondindex in 0..<legs.count {     //for each leg
                    
                    let steps = legs[secondindex]["steps"]  //get different steps
                    self.routesLoopCallCounter += 1
                    for thirdindex in 0..<steps.count { //for each step
                        callCounter += 1
                        //get start and end coordinates
                        var elevationAngle = 0.0
                        let startLatitude = steps[thirdindex]["start_location"]["lat"].doubleValue
                        let startLongitude = steps[thirdindex]["start_location"]["lng"].doubleValue
                        let endLatitude = steps[thirdindex]["end_location"]["lat"].doubleValue
                        let endLongitude = steps[thirdindex]["end_location"]["lng"].doubleValue
                        
                        //get the distance between start and end in meters
                        let distance  = steps[thirdindex]["distance"]["value"].doubleValue
                        let segmentStartCoordinate  = CLLocationCoordinate2DMake(startLatitude, startLongitude)
                        let segmentEndCoordinate  = CLLocationCoordinate2DMake(endLatitude, endLongitude)
                        
                        //calculate the angle between the step and the sea level
                        self.calculateAngle(segmentStart: segmentStartCoordinate, segmentEnd: segmentEndCoordinate, distance: distance, completion: { (returnedAngle) in
                            elevationAngle = returnedAngle
                            totalDistance += (distance)
                            angleValues.append(elevationAngle)
                            weights.append(distance)
                            
                            callCounter -= 1
                            if callCounter == 0 {
                                
                                weights = weights.map {$0 / totalDistance} //multiplier to make numbers bigger for better comparison
                                print(weights) //check if division is complete
                                
                                //calculate average angle for the route and add it to the average angle array
                                
                                let averageAngle = self.calculateAverageAngle(angles: angleValues, weights: weights)
                                averageAngles.append(averageAngle)
                                self.routesLoopCallCounter -= 1
                                
                            }
                            //finds and draws the flattest route if it exists, if not gives an alert
                            self.identifyFlattestRoute(averageAngles: averageAngles, routes: routes)
                        })
                        
                    }
                }
            }
            
        }
        
    }
    
    //MARK: - Functions
    
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    func drawPath( routes: [JSON], minIndex: Int)   //draws path for the routes. while making the one with minimum average angle boldest
    {
        
        for index in 0..<routes.count
        {
            let routeOverviewPolyline = routes[index]["overview_polyline"].dictionary
            let points = routeOverviewPolyline?["points"]?.stringValue
            let path = GMSPath.init(fromEncodedPath: points!)
            let polyline = GMSPolyline.init(path: path)
            if index == minIndex {
                polyline.strokeWidth = 20
                polyline.strokeColor = .green
            } else {
                polyline.strokeWidth = 7
                polyline.strokeColor = .random()
            }
            
            polyline.map = self.myMapView
        }
    }
    
    func calculateAngle(segmentStart: CLLocationCoordinate2D, segmentEnd: CLLocationCoordinate2D, distance: Double, completion: @escaping (Double) -> (Void)) {
        
        //calculates the angle (in radians) between a step and the surface
        
        let origin = "\(segmentStart.latitude),\(segmentStart.longitude)"
        let destination = "\(segmentEnd.latitude),\(segmentEnd.longitude)"
        var originElevation = 0.0
        var destinationElevation = 0.0
        var angle = 0.0
        let myoriginurl = "https://maps.googleapis.com/maps/api/elevation/json?locations=\(origin)&key=AIzaSyCDnPJTbKCTuVPKJm4q_KCm0Fipz7d3Tfg"
        Alamofire.request(myoriginurl).responseJSON { response in
            
            let json = JSON(data: response.data!)
            print(json)
            originElevation = json["results"][0]["elevation"].doubleValue
            print(originElevation)
        }
        let mydestinationurl = "https://maps.googleapis.com/maps/api/elevation/json?locations=\(destination)&key=AIzaSyCDnPJTbKCTuVPKJm4q_KCm0Fipz7d3Tfg"
        Alamofire.request(mydestinationurl).responseJSON { response in
            
            let json = JSON(data: response.data!)
            print(json)
            destinationElevation = json["results"][0]["elevation"].doubleValue
            print(destinationElevation)
            print("I will work")
            let elevationDifference = abs(destinationElevation-originElevation)
            let ratio  = elevationDifference/distance
            angle = acos(ratio)
            print(angle)
            completion(angle)
        }
    }
    
    func calculateAverageAngle(angles: [Double], weights: [Double]) -> Double { //calculates the average angle
        var average: Double = 0
        for index in 0..<angles.count {
            average += angles[index]*weights[index]
        }
        return average
    }
    
    func giveAlert (title: String, message: String, actionTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func setupActivityIndicator() {
        activityIndicator.center = self.myMapView.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.backgroundColor = UIColor.green
        myMapView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    func identifyFlattestRoute(averageAngles: [Double], routes: [JSON]) {
        if self.routesLoopCallCounter == 0 {
            if let minimumAngle  = averageAngles.min() {
                let indexOfMinimumAngle = averageAngles.index(of: minimumAngle)
                self.activityIndicator.stopAnimating()
                //now we need to draw the routes making the one with smalest angle the boldest
                self.drawPath(routes: routes, minIndex: indexOfMinimumAngle!)
                //completing navigation formatting
                self.myMapView.animate(toLocation: self.endingLocation!)
                let marker = GMSMarker(position: self.endingLocation!)
                marker.title = self.finalPlace?.name
                marker.snippet = self.finalPlace?.formattedAddress
                marker.map = self.myMapView
                
            } else {
                self.activityIndicator.stopAnimating()
                self.giveAlert(title: "Invalid Destination", message: "You cannot walk to specified destination", actionTitle: "Choose Another Destination")
                
            }
        }
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
        
        //show button
        
        
        navigatorButton.isUserInteractionEnabled = true
        navigatorButton.isHidden = false
        
        //change the text of button allowing user to choose another destination
        
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

extension CGFloat { //random function for CGFloat
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor { //gets random color
    static func random() -> UIColor {
        var randomcolor = UIColor(red:   .random(),
                                  green: .random(),
                                  blue:  .random(),
                                  alpha: 1.0)
        if randomcolor == UIColor.green {
            randomcolor = random()
        }
        
        return randomcolor
    }
}




