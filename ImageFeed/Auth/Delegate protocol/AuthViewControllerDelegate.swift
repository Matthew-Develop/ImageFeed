//
//  AuthViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Matthew on 18.02.2025.
//

import Foundation

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}
