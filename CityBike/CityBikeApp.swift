//
//  CityBikeApp.swift
//  CityBike
//
//  Created by Sergio Rodríguez Rama on 24/4/21.
//

import SwiftUI

@main
struct CityBikeApp: App {
    var body: some Scene {
        WindowGroup {
            let httpController = HttpController<Networks>()
            NetworksView(service: .http(from: httpController))
                .environmentObject(httpController)
        }
    }
}
