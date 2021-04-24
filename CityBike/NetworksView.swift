//
//  NetworksView.swift
//  CityBike
//
//  Created by Sergio Rodríguez Rama on 24/4/21.
//

import SwiftUI

struct NetworksView: View {

    @EnvironmentObject private var httpController: HttpController<Networks>

    private let service: Service<Networks>

    init(service: Service<Networks>) {
        self.service = service
    }

    var body: some View {
        List(service.get()?.networks ?? []) { network in
            Button {
                
            } label: {
                Text(network.name)
            }
        }
        .onAppear {
            guard notPreview else { return }
            httpController.fetch(URL(string: "https://api.citybik.es/v2/networks")!, defaultValue: .sample)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NetworksView(service: .mock(.sample))
    }
}
