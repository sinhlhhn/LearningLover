//

import Foundation

struct Root: Decodable {
    let items: [RemoteCategoryItem]
    
    var categories: [CategoryItem] {
        items.map { item in
            CategoryItem(id: item.id, name: item.name, image: item.image)
        }
    }
}

struct RemoteCategoryItem: Equatable, Decodable {
    let id: UUID
    let name: String
    let image: String
    
    init(id: UUID, name: String, image: String) {
        self.id = id
        self.name = name
        self.image = image
    }
}
