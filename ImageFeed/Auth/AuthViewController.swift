//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Matthew on 14.02.2025.
//

import UIKit
import ProgressHUD

final class AuthViewController: UIViewController {
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: Private Properties
    private let oAuthService = OAuth2Service.shared
    private var alertPresenter: AlertPresenter?
    
    //MARK: Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertPresenter = AlertPresenter(viewController: self, delegate: self)
        
        setupView()
    }
    
    // MARK: Private Methods
    private func setupView() {
        view.backgroundColor =  .ypBlack
        
        addLoginButton()
        addUnsplashLogo()
    }
    
    private func addLoginButton() {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(didLoginButtonTapped), for: .touchUpInside)
        
        button.setTitle("Войти", for: .normal)
        button.setTitleColor(.ypBlack, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        button.backgroundColor = .ypWhite
        button.layer.cornerRadius = 15
        
        button.autoResizeOff()
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 48),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90)
        ])
    }
    
    private func addUnsplashLogo() {
        let image = UIImageView(image: UIImage(named: "logo_unsplash"))
        
        image.autoResizeOff()
        view.addSubview(image)
        NSLayoutConstraint.activate([
            image.heightAnchor.constraint(equalToConstant: 60),
            image.widthAnchor.constraint(equalToConstant: 60),
            
            image.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            image.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc private func didLoginButtonTapped(_ sender: UIButton!) {
        guard let webViewViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "WebViewViewController") as? WebViewViewController else { return }
        
        webViewViewController.delegate = self
        webViewViewController.modalPresentationStyle = .fullScreen
        present(webViewViewController, animated: true)
        
        UIView.animate(withDuration: 0.3) {
            sender.alpha = 0.7
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 ) {
            UIView.animate(withDuration: 0.3) {
                sender.alpha = 1.0
            }
        }
    }
}

extension AuthViewController {
    private func showAuthAlertError(_ errorMessage: String) {
        alertPresenter?.showAlert(
            title: "Что-то пошло не так",
            message: "Не удалось войти в систему: \(errorMessage)",
            buttonTitle: "Ок") { [weak self] in
                self?.dismissAlert()
            }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        UIBlockingProgressHUD.show()
        
        oAuthService.loadToken(code: code) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self = self else { return }
        
            switch result {
            case .success:
                self.delegate?.didAuthenticate(self)
            case .failure(let error):
                let errorMessage = error.localizedDescription.components(separatedBy: "(")[0]
                print(errorMessage)
                self.showAuthAlertError(String(errorMessage))
            }
        }
    }
    
    func webViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}

extension AuthViewController: AlertPresenterDelegate {
    func dismissAlert() { }
}
