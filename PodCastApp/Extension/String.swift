//
//  String.swift
//  PodCastApp
//
//  Created by Omar Khaled on 11/09/2022.
//

import Foundation

extension String {
    func toHttps()->String {
        return self.contains("https") ? self : self.replacingOccurrences(of: "http", with: "https")
    }
}
