# CityBikes

The goal of this project is to put Protocol Witnesses into practice along with Combine and SwiftUI.

## API

The app will consume the [CityBikes API](http://api.citybik.es/v2/).

### Network

With a GET request to [http://api.citybik.es/v2/networks](http://api.citybik.es/v2/networks) a list of all the available networks is fetched. Each network contains valuable information such as the name of the company that offers the service, the location of the city and, most importantly, the path to fetch all the stations for each specific network.

```json
{
    "company": [
        "Comunicare S.r.l."
    ],
    "href": "/v2/networks/bicincitta-agglo-fribourg",
    "id": "bicincitta-agglo-fribourg",
    "location": {
        "city": "Fribourg",
        "country": "CH",
        "latitude": 46.8064773,
        "longitude": 7.161971899999999
    },
    "name": "Bicincittà",
    "source": "http://www.bicincitta.com/frmLeStazioni.aspx?ID=33",
    "stations": []
}
```

### Station

For example, with a GET request to [http://api.citybik.es/v2/networks/sitycleta-las-palmas-las-palmas-de-gran-canaria](http://api.citybik.es/v2/networks/sitycleta-las-palmas-las-palmas-de-gran-canaria), the network of the city of _Las Palmas de Gran Canaria_ is retrieved with all its stations.

Each station information will tell the number of empty slots, how many free bikes are there, the specific location of the station, the name of the station, IDs of the bikes, and more.

```json
{
    "empty_slots": 4,
    "extra": {
        "bike_uids": [
            "41037",
            "41067",
            "41216",
            "41362",
            "41307",
            "41119"
        ],
        "number": "3420",
        "slots": 10,
        "uid": "5368337"
    },
    "free_bikes": 6,
    "id": "21ffcc2a9f6eaedc49e1308b60362b0a",
    "latitude": 28.121295,
    "longitude": -15.42982,
    "name": "Piscina Julio Navarro",
    "timestamp": "2021-04-24T15:06:47.426000Z"
}
```

## Protocol Witnesses

Some things are impossible or very difficult to do using protocols, for example, building a generic interface for a service. An alternative, would be to use a struct whose properties are closures.

```swift
struct Service<T: Decodable> {
    let get: () -> T?
}
```

Using factory methods, the closures are initialized as needed in each case.

```swift
extension Service {

    static func mock(_ value: T) -> Self {
        .init(get: { value })
    }

    static func http(from controller: HttpController<T>) -> Self {
        .init(get: { controller.fetchedValue })
    }
}
```

For example, for injecting mock values into a view, just create a `Service.mock` and pass the mock values as parameters into the factory method.

```swift
static var previews: some View {
    NetworksView(service: .mock(.init(networks: [.init(id: "123", href: "ABC", name: "Test")])))
}
```

## Combine

On the other hand, fetching the values from a server using `URLSession` is not as straightforward. `Combine` is used to request the data and `SwiftUI` to paint it reactively.

To fetch the data, the management of the request is encapsulated into a generic controller so it can be reusable and declared as an `ObservableObject` so it can be observed from the view.

```swift
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
```

## SwiftUI

The view will have `HttpController` as an `EnvironmentObject`, so it will be refreshed when the `fetchedValue` of the controller is changed; and the data will be requested when the view appears.

```swift
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
```

The view can be initialized with mock values, as seen above, or with a `HttpController`.

```swift
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
```
