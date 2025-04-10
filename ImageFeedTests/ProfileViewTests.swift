//
//  ProfileViewTests.swift
//  ImageFeedTests
//
//  Created by Matthew on 10.04.2025.
//

import XCTest
import Foundation
@testable import ImageFeed

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    var viewDidLoadCalled = false
    var view: ProfileViewControllerProtocol?

    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func showLogoutAlert(view: UIViewController) {
    }
}
final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var updateProfileDataCalled = false
    var updateProfileImageCalled = false
    var presenter: ProfileViewPresenterProtocol?
    
    func updateProfileData(profile: Profile?) {
        updateProfileDataCalled = true
    }
    
    func updateProfileImage(url: URL?) {
        updateProfileImageCalled = true
    }
}

final class ProfileViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //Given
        let presenterSpy = ProfileViewPresenterSpy()
        let viewController = ProfileViewController()
        viewController.presenter = presenterSpy
        presenterSpy.view = viewController
        
        //When
        _ = viewController.view
        
        //Then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }
    
    func testPresenterCallsUpdateProfileData() {
        //Given
        let presenter = ProfileViewPresenter()
        let viewController = ProfileViewControllerSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //When
        presenter.viewDidLoad()
        
        //Then
        XCTAssertTrue(viewController.updateProfileDataCalled)
    }
    
    func testPresenterCallsUpdateProfileImage() {
        //Given
        let presenter = ProfileViewPresenter()
        let viewController = ProfileViewControllerSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //When
        presenter.viewDidLoad()
        
        //Then
        XCTAssertTrue(viewController.updateProfileImageCalled)
    }
    
    
}
