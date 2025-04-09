//
//  WebViewTests.swift
//  ImageFeedTests
//
//  Created by Matthew on 09.04.2025.
//

import XCTest
@testable import ImageFeed
import Foundation

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var viewDidLoadCalled = false
    var view: WebViewViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
    }
    
    func code(from url: URL) -> String? {
        return nil
    }
}
final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: WebViewPresenterProtocol?
    var isLoadRequestCalled = false
    
    func load(request: URLRequest) {
        isLoadRequestCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {
    }
    
    func setProgressHidden(_ isHidden: Bool) {
    }
}


final class WebViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //Given
        let view = WebViewViewController()
        let presenter = WebViewPresenterSpy()
        view.presenter = presenter
        presenter.view = view
        
        //When
        _ = view.view
        
        //Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsLoadRequest() {
        //Given
        let authHelperDummy: AuthHelperProtocol = AuthHelper()
        let view = WebViewViewControllerSpy()
        let presenter = WebViewPresenter(authHelper: authHelperDummy)
        view.presenter = presenter
        presenter.view = view
        
        //When
        presenter.viewDidLoad()
        
        //Then
        XCTAssertTrue(view.isLoadRequestCalled)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        //Given
        let authHelperDummy = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelperDummy)
        let progress: Float = 0.9
        
        //When
        let shouldHideProgress = presenter.shouldHideProgress(value: progress)
        
        //Then
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressHiddenWhenOne() {
        //Given
        let authHelperDummy = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelperDummy)
        let progress: Float = 1
        
        //When
        let shouldHideProgress = presenter.shouldHideProgress(value: progress)
        
        //Then
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthURL() {
        //Given
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        
        //When
        let url = authHelper.authURL()
        
        guard let urlString = url?.absoluteString else {
            XCTFail("URL string is nil")
            return
        }
        
        //Then
        XCTAssertTrue(urlString.contains(configuration.unsplashAuthorizeURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
        XCTAssertTrue(urlString.contains("code"))
    }
    
    func testCodeFromURL() {
        //Given
        let authHelper = AuthHelper()
        
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")
        urlComponents?.queryItems = [
            URLQueryItem(name: "code", value: "testCode")
        ]
        guard let url = urlComponents?.url else { return }
        
        //When
        let code = authHelper.code(from: url)
        
        //Then
        XCTAssertEqual(code, "testCode")
    }
    
    
}
