//
//  SearchResults.swift
//  PodCastApp
//
//  Created by Omar Khaled on 06/09/2022.
//

import Foundation

struct SearchResults:Decodable {
    let resultCount:Int
    let results:[Podcast]
    
    
}
