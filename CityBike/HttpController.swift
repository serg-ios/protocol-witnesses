//
//  HttpController.swift
//  CityBike
//
//  Created by Sergio Rodríguez Rama on 24/4/21.
//

import Foundation
import Combine

class HttpController<T: Decodable>: ObservableObject {

    private var requests = Set<AnyCancellable>()

    var fetchedValue: T? {
        willSet {
            objectWillChange.send()
        }
    }

    deinit {
        requests.forEach {
            $0.cancel()
        }
    }

    // MARK: - Public methods

    public func fetch(_ url: URL, defaultValue: T) {
        let decoder = JSONDecoder()
        URLSession.shared.dataTaskPublisher(for: url)
            .retry(1)
            .map(\.data)
            .decode(type: T.self, decoder: decoder)
            .replaceError(with: defaultValue)
            .receive(on: DispatchQueue.main)
            .sink { self.fetchedValue = $0 }
            .store(in: &requests)
    }
}
