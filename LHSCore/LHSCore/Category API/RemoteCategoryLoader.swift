//

import Foundation
import Combine

public protocol HTTPClient {
    func get(from url: URL) -> AnyPublisher<(Data, HTTPURLResponse), Error>
}

public final class RemoteCategoryLoader {
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public func load() -> AnyPublisher<[CategoryItem], Error> {
        return client.get(from: url)
            .tryMap { data, response in
                guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
                    throw Error.invalidData
                }
                return root.items
            }
            .mapError { $0 as? Error ?? Error.connectivity}
            .eraseToAnyPublisher()
    }
}

private struct Root: Decodable {
    let items: [CategoryItem]
}
