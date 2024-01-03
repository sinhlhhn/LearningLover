//

import XCTest

class RemoteCategoryLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}

final class RemoteCategoryLoaderTest: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient()
        _ = RemoteCategoryLoader()
        
        XCTAssertNil(client.requestedURL)
    }

}
