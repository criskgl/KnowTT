//
//  CustomAnnotation.swift
//  KnowTT
//
//  Created by CK on 02/03/2019.
//  Copyright © 2019 CK. All rights reserved.
//

import Foundation
import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
    let placeName: String?
    let placeLocationName: String?
    let description2: String
    let coordinate: CLLocationCoordinate2D
    init(placeName: String, placeLocationName: String, description:String, coordinate: CLLocationCoordinate2D) {
        self.placeName = placeName
        self.placeLocationName = placeLocationName
        self.description2  = description
        self.coordinate = coordinate
        super.init()
    }
}
