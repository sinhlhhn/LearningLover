//

import XCTest
import Combine
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
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        var cancellables = [AnyCancellable]()
        var errorCallCount = 0
        
        let expectation = expectation(description: "wait for loading")
        sut.load()
            .sink { completion in
                errorCallCount += 1
                expectation.fulfill()
            } receiveValue: { value in
                XCTFail("Expect failed, got \(value) instead")
            }
            .store(in: &cancellables)

        client.onCompleteFailure()
        
        wait(for: [expectation], timeout: 1)
        
        XCTAssertEqual(errorCallCount, 1)
    }

    //MARK: - Helpers:
    
    private func makeSUT(
        url: URL = URL(string: "http://a-default-url")!,
        client: HTTPCLientSpy = HTTPCLientSpy(state: PassthroughSubject<Void, Error>()))
    -> (RemoteCategoryLoader, HTTPCLientSpy) {
        
        let client = client
        let sut = RemoteCategoryLoader(url: url, client: client)
        
        return (sut, client)
    }
    
    private class HTTPCLientSpy: HTTPClient {
        var requestedURLs: [URL] = []
        let state: PassthroughSubject<Void, Error>
        
        init(state: PassthroughSubject<Void, Error>) {
            self.state = state
        }
        
        func get(from url: URL) -> AnyPublisher<Void, Error> {
            requestedURLs .append(url)
            return state.eraseToAnyPublisher()
        }
        
        func onCompleteFailure(with error: Error = NSError(domain: "e", code: -1)) {
            state.send(completion: .failure(error))
        }
    }
}
