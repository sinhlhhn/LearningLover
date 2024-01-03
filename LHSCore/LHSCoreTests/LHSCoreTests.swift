//

import XCTest
import LHSCore

class MemoryStore {
    func load() async throws -> [String] {
        return []
    }
}

class LHSCoreTests: XCTestCase {

    func test_init_displaysEmptyList() async throws {
        let sut = MemoryStore()
        
        let result = try await sut.load()
        
        XCTAssertEqual(result.count, 0)
    }

}
