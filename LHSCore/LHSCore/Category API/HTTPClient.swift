//

import Foundation
import Combine

public protocol HTTPClient {
    func get(from url: URL) -> AnyPublisher<(Data, HTTPURLResponse), Error>
}
