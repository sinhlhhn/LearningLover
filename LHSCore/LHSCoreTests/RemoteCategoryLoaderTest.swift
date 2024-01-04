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
    
    func test_load_deliverErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        [100, 199, 201, 300].enumerated().forEach { index, statusCode in
            expect(sut, expectedCompletion: .failure(.invalidData)) {
                client.onComplete(statusCode: statusCode, index: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        let invalidJSON = Data()
        expect(sut, expectedCompletion: .failure(.invalidData)) {
            client.onComplete(statusCode: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliversEmptyValueOn200HTTPResponseWithEmptyJSON() {
        let (sut, client) = makeSUT()
        let emptyJSON = Data("{\"items\": []}".utf8)
        expect(sut, expectedValue: []) {
            client.onComplete(statusCode: 200, data: emptyJSON)
        }
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        let uuid = UUID()

        let item = [
            "id": uuid.uuidString,
            "name": "food",
            "image": "ic_food"
        ]

        let jsonObject: [String: Any] = [
            "items": [item]
        ]
        
        let itemsJSON = try! JSONSerialization.data(withJSONObject: jsonObject)
        let expectedItem = [
            CategoryItem(id: uuid, name: "food", image: "ic_food")
        ]
        expect(sut, expectedValue: expectedItem) {
            client.onComplete(statusCode: 200, data: itemsJSON)
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
                XCTFail("Expect failed, got \(value) instead", file: file, line: line)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        action()
        
        wait(for: [expectation], timeout: 1)
        
        XCTAssertEqual(completion, expectedCompletion, file: file, line: line)
    }
    
    private func expect(_ sut: RemoteCategoryLoader, expectedValue: [CategoryItem], when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        var cancellables = [AnyCancellable]()
        
        var receivedValue: [CategoryItem] = []
        
        let expectation = expectation(description: "wait for loading")
        sut.load()
            .sink { completion in
                XCTFail("Expect receive value, got \(completion) instead", file: file, line: line)
                expectation.fulfill()
            } receiveValue: { value in
                receivedValue = value
                expectation.fulfill()
            }
            .store(in: &cancellables)

        action()
        
        wait(for: [expectation], timeout: 1)
        
        XCTAssertEqual(receivedValue, expectedValue, file: file, line: line)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var categoryMessages = [(url: URL, publisher: PassthroughSubject<(Data, HTTPURLResponse), Error>)]()
        
        var requestedURLs: [URL] {
            categoryMessages.map { $0.url }
        }
        
        func get(from url: URL) -> AnyPublisher<(Data, HTTPURLResponse), Error> {
            let publisher = PassthroughSubject<(Data, HTTPURLResponse), Error>()
            categoryMessages.append((url, publisher))
            return publisher.eraseToAnyPublisher()
        }
        
        func onCompleteFailure(with error: Error = NSError(domain: "e", code: -1), at index: Int = 0) {
            categoryMessages[index].publisher.send(completion: .failure(error))
        }
        
        func onComplete(statusCode: Int, data: Data = Data(), index: Int = 0) {
            let response = HTTPURLResponse(
                url: categoryMessages[index].url,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            categoryMessages[index].publisher.send((data, response))
        }
    }
}

private func anyError() -> Error {
    NSError(domain: "e", code: -1)
}
