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
    func zoomToPosition(coordinates: CLLocationCoordinate2D, _ latitudinalMeters: CLLocationDistance = 7500, _ longitudinalMeters: CLLocationDistance = 7500) {
        let region = MKCoordinateRegionMakeWithDistance(coordinates, latitudinalMeters, longitudinalMeters)
        self.setRegion(region, animated: true)
    }
}