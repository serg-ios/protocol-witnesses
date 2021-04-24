//
//  Service.swift
//  CityBike
//
//  Created by Sergio Rodríguez Rama on 24/4/21.
//

import Foundation

struct Service<T: Decodable> {
    let get: () -> T?
}

extension Service {

    static func mock(_ value: T) -> Self {
        .init(get: { value })
    }

    static func http(from controller: HttpController<T>) -> Self {
        .init(get: { controller.fetchedValue })
    }
}
