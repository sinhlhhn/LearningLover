//

import XCTest
import Combine

class RemoteCategoryLoader {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load() {
        client.get(from: URL(string: "http://a-url.com")!)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class HTTPCLientSpy: HTTPClient {
    var requestedURL: URL?
    
    func get(from url: URL) {
        self.requestedURL = url
    }
}

final class RemoteCategoryLoaderTest: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPCLientSpy()
        _ = RemoteCategoryLoader(client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let client = HTTPCLientSpy()
        let sut = RemoteCategoryLoader(client: client)
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }

}
