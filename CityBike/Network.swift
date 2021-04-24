//
//  Network.swift
//  CityBike
//
//  Created by Sergio Rodríguez Rama on 24/4/21.
//

import Foundation

struct Network: Decodable, Identifiable, Equatable {
    var id: String
    var href: String
    var name: String
}
