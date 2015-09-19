//
//  MKMapView.swift
//  Lome
//
//  Created by Tobias Feistmantl on 19/09/15.
//  Copyright © 2015 Tobias Feistmantl. All rights reserved.
//

import Foundation
import MapKit

extension MKMapView {
    func zoomToPosition(coordinates: CLLocationCoordinate2D) {
        let region = MKCoordinateRegionMakeWithDistance(coordinates, 10000, 10000)
        self.setRegion(region, animated: true)
    }
}