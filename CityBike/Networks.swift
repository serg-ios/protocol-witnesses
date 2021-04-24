//
//  Networks.swift
//  CityBike
//
//  Created by Sergio Rodríguez Rama on 24/4/21.
//

import Foundation

struct Networks: Decodable, Equatable {

    static var sample: Networks {
        .init(networks: [.init(id: "123", href: "ABC", name: "Test")])
    }

    var networks: [Network]
}
