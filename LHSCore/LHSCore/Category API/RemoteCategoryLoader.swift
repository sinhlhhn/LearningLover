//

import Foundation
import Combine

public protocol HTTPClient {
    func get(from url: URL) -> AnyPublisher<Void, Error>
}

public final class RemoteCategoryLoader {
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load() -> AnyPublisher<Void, Error> {
        return client.get(from: url)
    }
}
