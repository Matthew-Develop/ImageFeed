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
    var showLogoutAlertCalled = false
    var view: ProfileViewControllerProtocol?

    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func showLogoutAlert(view: UIViewController) {
        showLogoutAlertCalled = true
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
    
    func testViewControllerCallsLogoutAlert() {
        //Given
        let viewController = ProfileViewController()
        let presenterSpy = ProfileViewPresenterSpy()
        viewController.presenter = presenterSpy
        presenterSpy.view = viewController
        
        //When
        viewController.showLogoutAlert()
        
        //Then
        XCTAssertTrue(presenterSpy.showLogoutAlertCalled)
    }
    
    func testPresenterCallsUpdateProfileData() {
        //Given
        let presenter = ProfileViewPresenter()
        let viewControllerSpy = ProfileViewControllerSpy()
        viewControllerSpy.presenter = presenter
        presenter.view = viewControllerSpy
        
        //When
        presenter.viewDidLoad()
        
        //Then
        XCTAssertTrue(viewControllerSpy.updateProfileDataCalled)
    }
    
    func testPresenterCallsUpdateProfileImage() {
        //Given
        let presenter = ProfileViewPresenter()
        let viewControllerSpy = ProfileViewControllerSpy()
        viewControllerSpy.presenter = presenter
        presenter.view = viewControllerSpy
        
        //When
        presenter.viewDidLoad()
        
        //Then
        XCTAssertTrue(viewControllerSpy.updateProfileImageCalled)
    }
}
