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
            print("Information about starting location: \(startingLocation?.latitude ?? 0)   \( startingLocation?.longitude ?? 0)")
        }
        
        myMapView.settings.myLocationButton = true
        myMapView.settings.allowScrollGesturesDuringRotateOrZoom = true
        myMapView.settings.zoomGestures = true
        
        //End of configuration of current location
        
        //Recognizes tap gesture on the screen so you can remove keyboard
        
        let tapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        
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
                print("Information about starting location: \(startingLocation?.latitude ?? 0)   \( startingLocation?.longitude ?? 0)")
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
        present(autocompleteController, animated: true, completion: nil)
    }
    
    //MARK: - Functions
    
    func dismissKeyboard(){
        self.view.endEditing(true)
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
        
        let marker = GMSMarker(position: endingLocation!)
        marker.title = place.name
        marker.snippet = place.formattedAddress
        marker.map = myMapView
        
        //delete the choosedestination button
        
        chooseDestinationButton.isHidden = true
        chooseDestinationButton.isUserInteractionEnabled = false
        
        //move the map up
        
        myMapTopConstraint.constant = 0
        
        //show button
        
        
        navigatorButton.isUserInteractionEnabled = true
        navigatorButton.isHidden = false
        
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

//MARK: - Helper functions



