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
        let region = MKCoordinateRegionMakeWithDistance(coordinates, 7500, 7500)
        self.setRegion(region, animated: true)
    }
}