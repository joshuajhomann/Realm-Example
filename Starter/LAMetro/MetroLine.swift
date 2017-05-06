//
//  MetroLine.swift
//  LAMetro
//
//  Created by Joshua Homann on 4/29/17.
//  Copyright © 2017 josh. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift


struct MetroLine: Mappable {
    // "display_name": "2 Downtown LA - Pacific Palisades Via", "id": "2"
    var id: String = ""
    var name: String = ""

    var lineName: String {
        return name.components(separatedBy: " ").dropFirst().joined(separator: " ")
    }

    var lineNumber: String {
        return name.components(separatedBy: " ").first ?? ""
    }

    var isFavorite: Bool {
        set {
            if newValue {
                MetroLine.favorites.insert(id)
            } else {
                MetroLine.favorites.remove(id)
            }
            UserDefaults.standard.set(Array(MetroLine.favorites), forKey: "favorites")
        }
        get {
            return MetroLine.favorites.contains(id)
        }
    }

    static var favorites = Set<String>(UserDefaults.standard.array(forKey: "favorites") as? [String] ?? [])

    init?(map: Map) {
        guard map.JSON[API.Key.id] != nil else {
            return nil
        }
    }

    mutating func mapping(map: Map) {
        id <- map[API.Key.id]
        name <- map[API.Key.displayName]
    }
}


// MARK: API Calls
extension MetroLine {
    static func getAll(completion: @escaping APICallback<[MetroLine]>) {
        API.requestArray(from: API.Path.routes, completion: completion)
    }

    func getStops(completion: @escaping APICallback<[MetroStop]>) {
        let path = API.Path.stops.replacingOccurrences(of: API.placeholder, with: id.description)
        API.requestArray(from: path, completion: completion)
    }
}
