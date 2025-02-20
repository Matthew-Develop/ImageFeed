//
//  WebViewViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Matthew on 15.02.2025.
//

import Foundation

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewControllerDidCancel(_ vc: WebViewViewController)
}
