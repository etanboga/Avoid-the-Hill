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



let CORNERRADIUS = 4

class ViewController: UIViewController, CLLocationManagerDelegate  {
    
    //MARK: - Properties
    
    @IBOutlet weak var chooseDestinationButton: UIButton!
    @IBOutlet weak var myMapView: GMSMapView!
    
    let manager = CLLocationManager()
    var startingLocation : CLLocationCoordinate2D? = nil
    var endingLocation : CLLocationCoordinate2D? = nil
    //var resultsViewController : GMSAutocompleteResultsViewController?
    //var searchController : UISearchController?
    //var resultView: UITextView?


    
    
    //MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chooseDestinationButton.layer.cornerRadius = CGFloat(CORNERRADIUS)
        
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
        
        //End of configuration of current location
        
        //Recognizes tap gesture on the screen so you can remove keyboard
        
        let tapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        //Search autocomplete part
        
//        resultsViewController = GMSAutocompleteResultsViewController()
//        resultsViewController?.delegate = self
//        
//        searchController = UISearchController(searchResultsController: resultsViewController)
//        searchController?.searchResultsUpdater = resultsViewController
//        
//        let frameWidth: CGFloat  = 300.0
//        let frameHeight: CGFloat  = 45.0
//        let xbound: CGFloat = (view.bounds.width / 2) - (frameWidth / 2)
//        let ybound: CGFloat = (view.bounds.height / 2) - (view.bounds.height/8)     //works on phone
//        
//        let subView = UIView(frame: CGRect(x: xbound, y: ybound, width: frameWidth, height: frameHeight))
//        
//        subView.addSubview((searchController?.searchBar)!)
//        view.addSubview(subView)
//        searchController?.searchBar.sizeToFit()
//        searchController?.hidesNavigationBarDuringPresentation = false
//        
//        searchController?.searchBar.placeholder = "Enter Final Destination"
//        
//        // When UISearchController presents the results view, present it in
//        // this view controller, not one further up the chain.
//        definesPresentationContext = true
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print(manager.location ?? "no location")
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

//extension ViewController: GMSAutocompleteResultsViewControllerDelegate {
//    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
//                           didAutocompleteWith place: GMSPlace) {
//        searchController?.isActive = false
//        // Do something with the selected place.
////        print("Place name: \(place.name)")
////        print("Place address: \(String(describing: place.formattedAddress))")
////        print("Place attributions: \(String(describing: place.attributions))")
//        let finalDestination = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude)
//        self.endingLocation = finalDestination
//        print("Information about ending location: \(endingLocation?.latitude ?? 0)  \(endingLocation?.longitude ?? 0)")
//    }
//    
//    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
//                           didFailAutocompleteWithError error: Error){
//        // TODO: handle the error.
//        print("Error: ", error.localizedDescription)
//    }
//    
//    // Turn the network activity indicator on and off again.
//    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//    }
//    
//    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
//    }
//    
//}

extension ViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        //print("Place name: \(place.name)")
        //print("Place address: \(place.formattedAddress)")
        //print("Place attributions: \(place.attributions)")
        let finalDestination = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude)
        self.endingLocation = finalDestination
        let camera = GMSCameraPosition.camera(withLatitude: (self.endingLocation?.latitude)!, longitude: (self.endingLocation?.longitude)!, zoom: 15)
        myMapView.camera = camera
        let marker = GMSMarker(position: endingLocation!)
        marker.title = place.name
        marker.snippet = place.formattedAddress
        marker.map = myMapView
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



