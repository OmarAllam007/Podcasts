//
//  UIApplication.swift
//  PodCastApp
//
//  Created by Omar Khaled on 21/09/2022.
//

import UIKit

extension UIApplication {
    static func mainTabBarController() -> MainTabBarController? {
//        return UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        
        return shared.keyWindow?.rootViewController as? MainTabBarController
    }
}
