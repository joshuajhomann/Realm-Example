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


class MetroLine: Object, Mappable {
    // "display_name": "2 Downtown LA - Pacific Palisades Via", "id": "2"
    dynamic var id: String = ""
    dynamic var name: String = ""
    dynamic var favorite = false

    var isFavorite: Bool {
        get {
            return favorite
        }
        set {
            if let realm = try? Realm() {
                try? realm.write {
                    favorite = newValue
                }
            }
        }
    }

    var stops = List<MetroStop>()
    var lineName: String {
        return name.components(separatedBy: " ").dropFirst().joined(separator: " ")
    }

    var lineNumber: String {
        return name.components(separatedBy: " ").first ?? ""
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
    }
}


// MARK: API Calls
extension MetroLine {
    static func getAll(completion: @escaping APICallback<[MetroLine]>) {
        API.requestArray(from: API.Path.routes, completion: completion)
    }

    func getStops(completion: @escaping APICallback<[MetroStop]>) {
        let path = API.Path.stops.replacingOccurrences(of: API.placeholder, with: id.description)
        let lineId = id
        API.requestArray(from: path) { (result: APIResult<[MetroStop]>) in
            switch result {
            case .success(let stops):
                if let realm = try? Realm() {
                    try? realm.write {
                        stops.enumerated().forEach {$0.element.sequence = $0.offset}
                        let line = realm.object(ofType: MetroLine.self, forPrimaryKey: lineId)
                        line?.stops.removeAll()
                        stops.forEach {line?.stops.append($0)}
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
