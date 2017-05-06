//
//  MetroStop.swift
//  LAMetro
//
//  Created by Joshua Homann on 4/29/17.
//  Copyright © 2017 josh. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import MapKit

//{"latitude": 34.0615399, "display_name": "Santa Monica / Avenue Of The Stars", "id": "05917", "longitude": -118.41797}
class MetroStop: Object, Mappable {
    dynamic var id = ""
    dynamic var latitude: Double = 0
    dynamic var longitude: Double = 0
    dynamic var name: String = ""
    dynamic var sequence: Int = 0

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    override static func primaryKey() -> String? {
        return "id"
    }

    override static func ignoredProperties() -> [String] {
        return [""]
    }

    required convenience init?(map: Map) {
        self.init()
        guard map.JSON[API.Key.id] != nil else {
            return nil
        }
    }

    func mapping(map: Map) {
        id <- map[API.Key.id]
        name <- map[API.Key.displayName]
        latitude <- map[API.Key.latitude]
        longitude <- map[API.Key.longitude]
    }

}
