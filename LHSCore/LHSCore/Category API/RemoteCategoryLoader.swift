//

import Foundation
import Combine

public protocol HTTPClient {
    func get(from url: URL) -> AnyPublisher<HTTPURLResponse, Error>
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
    
    public func load() -> AnyPublisher<Void, Error> {
        return client.get(from: url)
            .tryMap { response in
                guard response.statusCode == 200 else {
                    throw Error.invalidData
                }
            }
            .mapError { $0 as? Error ?? Error.connectivity}
            .eraseToAnyPublisher()
    }
}
