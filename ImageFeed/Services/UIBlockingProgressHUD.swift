//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Matthew on 03.03.2025.
//

import ProgressHUD
import UIKit


final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        UIApplication.shared.windows.first
    }
    
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animationType = .activityIndicator
        ProgressHUD.colorHUD = .ypWhiteAlpha50
        ProgressHUD.colorAnimation = .ypBackground
        
        ProgressHUD.animate()
    }
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
