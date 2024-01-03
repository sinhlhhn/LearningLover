//

import XCTest
import LHSCore

final class RemoteCategoryLoaderTest: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "http://a-given-url")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestDataFromURLTwice() {
        let url = URL(string: "http://a-given-url")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    //MARK: - Helpers:
    
    private func makeSUT(url: URL = URL(string: "http://a-default-url")!) -> (RemoteCategoryLoader, HTTPCLientSpy) {
        let client = HTTPCLientSpy()
        let sut = RemoteCategoryLoader(url: url, client: client)
        
        return (sut, client)
    }
    
    private class HTTPCLientSpy: HTTPClient {
        var requestedURLs: [URL] = []
        
        func get(from url: URL) {
            requestedURLs .append(url)
        }
    }
}
