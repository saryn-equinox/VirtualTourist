//
//  CoordinateExtension.swift
//  VirtualTourist
//
//  Created by 邱浩庭 on 7/1/2021.
//

import Foundation
import CoreData

/**
 Extense the CLLocationCoordinate2D struct to make it storable in the iOS property list
 Reference: https://stackoverflow.com/questions/18910612/store-cllocationcoordinate2d-to-nsuserdefaults
 */
extension CLLocationCoordinate2D: Equatable {
    private static let Lat = "lat"
    private static let Lon = "lon"

    typealias CLLocationDictionary = [String: CLLocationDegrees]

    var asDictionary: CLLocationDictionary {
        return [CLLocationCoordinate2D.Lat: self.latitude,
                CLLocationCoordinate2D.Lon: self.longitude]
    }
    
    init(dict: CLLocationDictionary) {
        self.init(latitude: dict[CLLocationCoordinate2D.Lat]!,
                  longitude: dict[CLLocationCoordinate2D.Lon]!)
    }
    
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return (lhs.longitude == rhs.longitude) && (lhs.latitude == rhs.latitude)
    }
}
