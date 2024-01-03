//

import XCTest
import LHSCore

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
