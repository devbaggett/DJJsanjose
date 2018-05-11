//
//  ViewController.swift
//  Map Kit Hackathon
//
//  Created by Devin Baggett on 5/10/18.
//  Copyright © 2018 devbaggett. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON

// MapViewController is a subclass of UIViewController
// MapViewController has IBOutlet to our MapKit
class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var venues = [Venue]()
    
    // parse json file and load in viewcontroller
    func fetchData() throws {
        let fileName = Bundle.main.path(forResource: "Venues", ofType: "json")
        let filePath = URL(fileURLWithPath: fileName!)
        var data: Data?
        do {
            data = try Data(contentsOf: filePath, options: Data.ReadingOptions(rawValue: 0))
        } catch let error {
            data = nil
            print("Report error \(error.localizedDescription)")
        }
        // when we get data, we turn json data in json format (unwrap json data)
        if let jsonData = data {
            let json = try JSON(data: jsonData)
            if let venueJSONs = json["response"]["venues"].array {
                for venueJSON in venueJSONs {
                    if let venue = Venue.from(json: venueJSON) {
                        self.venues.append(venue)
                    }
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServiceAuthenticationStatus()
        // set initial location for San Francisco
        let initialLocation = CLLocation(latitude: 37.7749, longitude: -122.431297)
        zoomMapOn(location: initialLocation)
        
        // create variable for pin/annotation
//        let sampleStarbucks = Venue(title: "Starbucks Imagination", locationName: "Imagination Street", coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.431297))
//        // add pin/annotation to mapView
//        mapView.addAnnotation(sampleStarbucks)

        mapView.delegate = self
        try! fetchData()
        mapView.addAnnotations(venues)
    }
    // radius around zoomMapOn = 1km ~ 1 mile = 1.6km
    private let regionRadius: CLLocationDistance = 1000
    // helper function
    func zoomMapOn(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: - Current Location
    var locationManager = CLLocationManager()
    
    // self explanatory
    func checkLocationServiceAuthenticationStatus() {
        // want self to be delegate
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            // if authorized
            mapView.showsUserLocation = true
            // start updating current location again
            locationManager.startUpdatingLocation()
        } else {
            // if not authorized, try when in use authentication
            locationManager.requestWhenInUseAuthorization()
            // allows current location to update
            locationManager.startUpdatingLocation()
        }
    }

}

// conform mapviewcontroller to cllocationmanager delegate
extension MapViewController: CLLocationManagerDelegate {
    // all methods are optionals so we don't need to implement
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // put all locations in locations array
        let location = locations.last!
        self.mapView.showsUserLocation = true
        // zoom map on current location
        zoomMapOn(location: location)
    }
}

// tell mapView we are conforming to MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    // gives us annotation of type MKAnnotation (requires a title and subtitle)
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // if annotation is indeed a venue that we create
        if let annotation = annotation as? Venue {
            // for different annotation views for dequeueing
            let identifier = "pin"
            var view: MKPinAnnotationView
            // if it goes through we create view, now we just dequeue and reuse that annotation view
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
            }
            return view
        }
        return nil
    }
    // when we tap into i button it will show info/details
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! Venue
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }
    
}

