//
//  Venue.swift
//  Map Kit Hackathon
//
//  Created by Devin Baggett on 5/11/18.
//  Copyright © 2018 devbaggett. All rights reserved.
//

import MapKit
// when we tap on annotation, an address pops up
import AddressBook
import SwiftyJSON

// conform to MKAnnotation. Put title and subtitle in annotation
class Venue: NSObject, MKAnnotation {
    let title: String?
    let locationName: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
    // turn JSON format into instance of Venue
    class func from(json: JSON) -> Venue? {
        var title: String
        if let unwrappedTitle = json["name"].string {
            // if we do get string title
            title = unwrappedTitle
        } else {
            title = ""
        }
        let locationName = json["location"]["address"].string
        let lat = json["location"]["lat"].doubleValue
        let long = json["location"]["lng"].doubleValue
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        return Venue(title: title, locationName: locationName, coordinate: coordinate)
    }
    // when annotation "i" is clicked, info will show
    func mapItem() -> MKMapItem {
        let addressDictionary = [String(kABPersonAddressStreetKey): subtitle]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        let mapItem = MKMapItem(placemark: placemark)
        
        // tell map item to be title
        mapItem.name = "\(title) - \(subtitle)"
        
        return mapItem
    }
}

