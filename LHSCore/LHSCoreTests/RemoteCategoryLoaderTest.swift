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
        
        _ = sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestDataFromURLTwice() {
        let url = URL(string: "http://a-given-url")!
        let (sut, client) = makeSUT(url: url)
        
        _ = sut.load()
        _ = sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, expectedCompletion: .failure(.connectivity)) {
            client.onCompleteFailure()
        }
    }

    //MARK: - Helpers:
    
    private func makeSUT(
        url: URL = URL(string: "http://a-default-url")!)
    -> (RemoteCategoryLoader, HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let sut = RemoteCategoryLoader(url: url, client: client)
        
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteCategoryLoader, expectedCompletion: Subscribers.Completion<RemoteCategoryLoader.Error>, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        var cancellables = [AnyCancellable]()
        
        var completion: Subscribers.Completion<RemoteCategoryLoader.Error>?
        
        let expectation = expectation(description: "wait for loading")
        sut.load()
            .sink {
                completion = $0
                expectation.fulfill()
            } receiveValue: { value in
                XCTFail("Expect failed, got \(value) instead")
            }
            .store(in: &cancellables)

        action()
        
        wait(for: [expectation], timeout: 1)
        
        XCTAssertEqual(completion, expectedCompletion, file: file, line: line)
    }
    
    private func anyError() -> Error {
        NSError(domain: "e", code: -1)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] = []
        let state = PassthroughSubject<Void, Error>()
        
        func get(from url: URL) -> AnyPublisher<Void, Error> {
            requestedURLs .append(url)
            return state.eraseToAnyPublisher()
        }
        
        func onCompleteFailure(with error: Error = NSError(domain: "e", code: -1)) {
            state.send(completion: .failure(error))
        }
    }
}
