//

import Foundation

public struct CategoryItem: Equatable {
    public let id: UUID
    public let name: String
    public let image: String
    
    public init(id: UUID, name: String, image: String) {
        self.id = id
        self.name = name
        self.image = image
    }
}

extension CategoryItem: Decodable {}
