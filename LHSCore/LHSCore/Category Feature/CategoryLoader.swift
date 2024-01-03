//

import Foundation
import Combine

protocol CategoryLoader {
    func load() -> AnyPublisher<([CategoryItem]), Error>
}
