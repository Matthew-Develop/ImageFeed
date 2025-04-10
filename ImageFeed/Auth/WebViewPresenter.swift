//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Matthew on 09.04.2025.
//

import Foundation

public protocol WebViewPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
    var view: WebViewViewControllerProtocol? { get set }
}

final class WebViewPresenter: WebViewPresenterProtocol {
    //MARK: Public Properties
    weak var view: WebViewViewControllerProtocol?
    var authHelper: AuthHelperProtocol
    
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }
    
    //MARK: Public Functions
    func viewDidLoad() {
        guard let request = authHelper.authRequest() else { return }
                
        view?.load(request: request)
        didUpdateProgressValue(0)
    }
    
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHidden = shouldHideProgress(value: newProgressValue)
        view?.setProgressHidden(shouldHidden)
    }
    
    func shouldHideProgress(value: Float) -> Bool {
        abs(value - 1) <= 0.001
    }
}
