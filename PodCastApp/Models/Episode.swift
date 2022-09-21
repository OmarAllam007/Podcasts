//
//  Episodes.swift
//  PodCastApp
//
//  Created by Omar Khaled on 09/09/2022.
//

import Foundation
import FeedKit

struct Episode {
    let title:String?
    let pubDate:Date?
    let description:String?
    var imageUrl:String?
    var author:String?
    var streamUrl:String
    
    init(feedItem:RSSFeedItem){
        
        self.title = feedItem.title ?? ""
        self.pubDate = feedItem.pubDate ?? Date()
        self.description = feedItem.iTunes?.iTunesSubtitle ?? ""
        self.imageUrl = feedItem.iTunes?.iTunesImage?.attributes?.href
        self.author = feedItem.iTunes?.iTunesAuthor ?? ""
        self.streamUrl =  feedItem.enclosure?.attributes?.url ?? ""
    }
}
