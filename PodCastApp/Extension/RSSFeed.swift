//
//  RSSFeed.swift
//  PodCastApp
//
//  Created by Omar Khaled on 14/09/2022.
//

import FeedKit

extension RSSFeed {
    func toEpisodes() -> [Episode] {
        let imageUrl = iTunes?.iTunesImage?.attributes?.href
        
        var episodes = [Episode]()
        
        items?.forEach({ feedItem in
            var episode:Episode = .init(feedItem: feedItem)
            
            if episode.imageUrl == nil {
                episode.imageUrl = imageUrl
            }
            
            
            episodes.append(episode)
            
        })
        
        return episodes
    }
}
