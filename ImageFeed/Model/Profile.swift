//
//  Profile.swift
//  ImageFeed
//
//  Created by Matthew on 03.03.2025.
//

import UIKit

struct Profile {
    let username: String
    var name: String
    var loginName: String {
        return "@\(username)"
    }
    var bio: String? = nil
}

