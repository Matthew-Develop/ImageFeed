//
//  ImagesListServiceTests.swift
//  ImagesListServiceTests
//
//  Created by Matthew on 24.03.2025.
//

import XCTest
@testable import ImageFeed

final class ImahgesListServiceTests: XCTestCase {
    func testExample() {
        let service = ImagesListService.shared
        
        let expectation = self.expectation(description: "Wait for notification")
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { _ in
                expectation.fulfill()
            }

        service.fetchPhotosNextpage { result in
            switch result {
            case .success(let photos):
                print(photos.isEmpty ? "No photos" : "\(photos.count) photos")
            case .failure(let error):
                print(error)
            }
        }

        wait(for: [expectation], timeout: 10)

        XCTAssertEqual(service.photos.count, 10)
    }
}
