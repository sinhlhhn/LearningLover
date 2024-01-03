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

final class RemoteCategoryLoaderTest: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "http://a-given-url")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, url)
    }

    //MARK: - Helpers:
    
    private func makeSUT(url: URL = URL(string: "http://a-default-url")!) -> (RemoteCategoryLoader, HTTPCLientSpy) {
        let client = HTTPCLientSpy()
        let sut = RemoteCategoryLoader(url: url, client: client)
        
        return (sut, client)
    }
    
    private class HTTPCLientSpy: HTTPClient {
        var requestedURL: URL?
        
        func get(from url: URL) {
            self.requestedURL = url
        }
    }
}
