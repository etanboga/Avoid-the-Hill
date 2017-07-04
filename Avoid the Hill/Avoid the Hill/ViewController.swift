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
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        let myLongitude = manager.location!.coordinate.longitude
        let myLatitude = manager.location!.coordinate.latitude
        //print("\(myLatitude)       \(myLongitude)")
        let camera = GMSCameraPosition.camera(withLatitude: myLatitude, longitude: myLongitude, zoom: 10)
        myMapView.camera = camera
        //myMapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: myMapView.frame.width, height: myMapView.frame.height), camera: camera)
//        mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: myMapView.frame.width, height: myMapView.frame.height), camera: camera)
        let currentLocation = CLLocationCoordinate2DMake(myLatitude, myLongitude)
        
        //self.view.addSubview(mapView!)
       //self.myMapView.addSubview(mapView!)
     //  myMapView = mapView
        
        myMapView.isMyLocationEnabled = true
        startingLocation = currentLocation
        
        myMapView.settings.myLocationButton = true
        
        let tapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
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

