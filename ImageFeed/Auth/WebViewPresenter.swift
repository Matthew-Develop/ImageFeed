//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Matthew on 09.04.2025.
//

import Foundation

public protocol WebViewPresenterProtocol: AnyObject {
    var view: WebViewViewControllerProtocol? { get set }
}

final class WebViewPresenter: WebViewPresenterProtocol {
    weak var view: WebViewViewControllerProtocol?
    
    
}
