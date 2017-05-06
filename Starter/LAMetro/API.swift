//
//  API.swift
//  LAMetro
//
//  Created by Joshua Homann on 4/29/17.
//  Copyright © 2017 josh. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

enum APIResult<T> {
    case success(T), failure(Error)
}

typealias APICallback<T> = (APIResult<T>) -> Void

struct API {
    static let baseURL = "http://api.metro.net/agencies/lametro/"
    static let placeholder = ":id"
    struct Path {
        static let routes = "routes/"
        static let stops = "routes/:id/sequence/"
    }
    struct Key {
        static let id = "id"
        static let displayName = "display_name"
        static let latitude = "latitude"
        static let longitude = "longitude"
    }
    static func requestArray<T> (from path: String,
                                 completion: @escaping APICallback<[T]>) where T: Mappable {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let apiURL = baseURL + path
        Alamofire.request(apiURL).responseArray(keyPath: "items") { (response: DataResponse<[T]>) in
                print("PATH: \(apiURL)")
                print("RESPONSE: \(String(data: response.data ?? Data(), encoding: .utf8) ?? "<NO DATA>")")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                switch response.result {
                case .success(let array):
                    completion(.success(array))
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }

}
