//

import XCTest
import Combine

class RemoteCategoryLoader {
    let url: URL
    let client: HTTPClient
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load() {
        client.get(from: url)
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
        let url = URL(string: "http://a-given-url")!
        let client = HTTPCLientSpy()
        _ = RemoteCategoryLoader(url: url, client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "http://a-given-url")!
        let client = HTTPCLientSpy()
        let sut = RemoteCategoryLoader(url: url, client: client)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, url)
    }

}
