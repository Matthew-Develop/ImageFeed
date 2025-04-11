//
//  ImagesListViewTests.swift
//  ImageFeedTests
//
//  Created by Matthew on 11.04.2025.
//

import XCTest
import Foundation
@testable import ImageFeed

final class ImagesListViewPresenterSpy: ImagesListViewPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    var photos: [Photo] = []
    
    var viewDidLoadCalled = false
    var displayPhotosCalled = false
    var configCellCalled = false
    var updateTableViewAnimatedCalled = false
    var didTapLikeButtonTableViewCalled = false
    var didTapLikeButtonSingleImageViewCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func displayPhotos(indexPath: IndexPath) {
        displayPhotosCalled = true
    }
    
    func configCell(for cell: ImageFeed.ImagesListCell, with indexPath: IndexPath) {
        configCellCalled = true
    }
    
    func updateTableViewAnimated() {
        updateTableViewAnimatedCalled = true
    }
    
    func didTapLikeButtonTableView(cell: ImageFeed.ImagesListCell, view: UIViewController) {
        didTapLikeButtonTableViewCalled = true
    }
    
    func didTapLikeButtonSingleImageView(_ singleImageViewController: ImageFeed.SingleImageViewController) {
        didTapLikeButtonSingleImageViewCalled = true
    }
}

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var reloadTableRowCalled = false
    var insertTableRowsCalled = false
    var getIndexPathCalled = false

    var presenter: ImagesListViewPresenterProtocol?

    func reloadTableRow(indexPath: IndexPath) {
        reloadTableRowCalled = true
    }
    
    func insertTableRows(indexPathArray: [IndexPath]) {
        insertTableRowsCalled = true
    }
    
    func getIndexPath(from cell: ImageFeed.ImagesListCell) -> IndexPath? {
        getIndexPathCalled = true
        return nil
    }
}

final class ImagesListViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //Given
        let presenterSpy = ImagesListViewPresenterSpy()
        let view = ImagesListViewController()
        view.presenter = presenterSpy
        presenterSpy.view = view
        
        //When
        _ = view.view
        
        //Then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }
    
    func testViewControllerCallsDisplayPhotos() {
        //Given
        let presenterSpy = ImagesListViewPresenterSpy()
        let view = ImagesListViewController()
        view.presenter = presenterSpy
        presenterSpy.view = view
        
        //When
        view.tableView(UITableView(), willDisplay: ImagesListCell(), forRowAt: IndexPath(row: 0, section: 0))
        
        //Then
        XCTAssertTrue(presenterSpy.displayPhotosCalled)
    }
    
    func testViewControllerCallsConfigCell() {
        //Given
        let presenterSpy = ImagesListViewPresenterSpy()
        let view = ImagesListViewController()
        view.presenter = presenterSpy
        presenterSpy.view = view
        
        let tableViewDummy = UITableView()
        tableViewDummy.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableViewDummy.dataSource = view
        
        //When
        _ = view.tableView(tableViewDummy, cellForRowAt: IndexPath(row: 0, section: 0))
        
        //Then
        XCTAssertTrue(presenterSpy.configCellCalled)
    }
    
    func testViewControllerCallsUpdateTableViewAnimated() {
        //Given
        let presenterSpy = ImagesListViewPresenterSpy()
        let view = ImagesListViewController()
        view.presenter = presenterSpy
        presenterSpy.view = view
        
        //When
        _ = view.view
    
        NotificationCenter.default
            .post(
                name: ImagesListService.didChangeNotification,
                object: nil
            )

        //Then
        XCTAssertTrue(presenterSpy.updateTableViewAnimatedCalled)
    }
    
    func testViewControllerCallsDidTapLikeButtonTableView() {
        //Given
        let presenterSpy = ImagesListViewPresenterSpy()
        let view = ImagesListViewController()
        view.presenter = presenterSpy
        presenterSpy.view = view
        
        //When
        view.didTapLikeButtonTableView(cell: ImagesListCell())
        
        //Then
        XCTAssertTrue(presenterSpy.didTapLikeButtonTableViewCalled)
    }
    
    func testViewControllerCallsDidTapLikeButtonSingleImageView() {
        //Given
        let presenterSpy = ImagesListViewPresenterSpy()
        let view = ImagesListViewController()
        view.presenter = presenterSpy
        presenterSpy.view = view
        
        //When
        view.didTapLikeButtonSingleImageView(singleImageViewController: SingleImageViewController())
        
        //Then
        XCTAssertTrue(presenterSpy.didTapLikeButtonSingleImageViewCalled)
    }
    
    func testPresenterCallsInsertTableRows() {
        //Given
        let presenter = ImagesListViewPresenter()
        let viewSpy = ImagesListViewControllerSpy()
        viewSpy.presenter = presenter
        presenter.view = viewSpy
        
        //When
        presenter.insertTableRows(
            indexPathArray: [IndexPath(row: 0, section: 0)]
        )
        
        //Then
        XCTAssertTrue(viewSpy.insertTableRowsCalled)
    }
    
    func testPresenterCallsReloadTableRow() {
        //Given
        let presenter = ImagesListViewPresenter()
        let viewSpy = ImagesListViewControllerSpy()
        viewSpy.presenter = presenter
        presenter.view = viewSpy
        
        //When
        presenter.reloadTableRow(indexPath: IndexPath(row: 0, section: 0))
        
        //Then
        XCTAssertTrue(viewSpy.reloadTableRowCalled)
    }
    
    func testPresenterCallsGetIndexPath() {
        //Given
        let presenter = ImagesListViewPresenter()
        let viewSpy = ImagesListViewControllerSpy()
        viewSpy.presenter = presenter
        presenter.view = viewSpy
        
        //When
        presenter.didTapLikeButtonTableView(cell: ImagesListCell(), view: UIViewController())
        
        //Then
        XCTAssertTrue(viewSpy.getIndexPathCalled)
    }
}
