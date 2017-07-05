//
//  ViewController.swift
//  Avoid the Hill
//
//  Created by Ege Tanboga on 7/4/17.
//  Copyright © 2017 Tanbooz. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps



let CORNERRADIUS = 4

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    //MARK: - Properties

    @IBOutlet weak var navigatorButton: UIButton!
    @IBOutlet weak var finalDestinationTextField: UITextField!
    
    @IBOutlet weak var myMapView: GMSMapView!
    
    let manager = CLLocationManager()
    var startingLocation : CLLocationCoordinate2D? = nil


    
    
    //MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigatorButton.layer.cornerRadius = CGFloat(CORNERRADIUS)
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest       //This part works for the phone because we have internal location services installed. It does not work on the simulator since we do not have access to the location while launching the app and then get the authorization to change our location
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        if let location = manager.location {
        let myLongitude = location.coordinate.longitude
        let myLatitude = location.coordinate.latitude
            let camera = GMSCameraPosition.camera(withLatitude: myLatitude, longitude: myLongitude, zoom: 10)
            myMapView.camera = camera
            let currentLocation = CLLocationCoordinate2DMake(myLatitude, myLongitude)
            myMapView.isMyLocationEnabled = true
            startingLocation = currentLocation
        }
        
        myMapView.settings.myLocationButton = true
        
        let tapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(manager.location ?? "no location")
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
    @IBAction func navigatiorButtonTapped(_ sender: UIButton) {
        //IMPLEMENT ALGORITHM HERE
    }
    
    //MARK: - Functions
    
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
}

