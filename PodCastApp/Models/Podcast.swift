//
//  Podcast.swift
//  PodCastApp
//
//  Created by Omar Khaled on 05/09/2022.
//

import Foundation

struct Podcast : Decodable {
    let trackName:String?
    let artistName:String?
    let artworkUrl600:String?
    let trackCount:Int?
    let feedUrl:String?

}
