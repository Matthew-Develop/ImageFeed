//
//  WebViewController.swift
//  ImageFeed
//
//  Created by Matthew on 14.02.2025.
//

import UIKit
@preconcurrency import WebKit

final class WebViewViewController: UIViewController {
    //MARK: IB Outlets
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    
    //MARK: Public Properties
    weak var delegate: WebViewViewControllerDelegate?
    
    //MARK: Private Properties
    private var estimatedProgressObservation: NSKeyValueObservation?

    //MARK: Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        progressView.progress = 0
        
        loadAuthView()
        
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [.new]
        ) { [weak self] _, _ in
            guard let self = self else { return }
            self.updateProgress()
        }
    
        webView.navigationDelegate = self
    }
    
    // MARK: IB Actions
    @IBAction func didTapBackAuthButton(_ sender: Any) {
        self.delegate?.webViewControllerDidCancel(self)
    }

    // MARK: Private Methods
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: Constants.unsplashAuthorizeURLString) else {
            print("ERROR Creating URL Components for WebView")
            return }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope),
        ]
        
        guard let url = urlComponents.url else {
            print("ERROR creating URL from URLComponents WebView")
            return }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: {$0.name == "code"} )
        {
            return codeItem.value
        } else {
            return nil
        }
    }
    
    private func updateProgress() {
        progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        progressView.isHidden = fabs(webView.estimatedProgress - 1) <= 0.001
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        progressView.progress = 0
        
        if let code = code(from: navigationAction) {
            self.delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
