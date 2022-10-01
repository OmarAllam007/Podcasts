//
//  UserDefault.swift
//  PodCastApp
//
//  Created by Omar Khaled on 27/09/2022.
//

import Foundation

extension UserDefaults {
    static let favouriteKey = "favouriteKey"
    static let downloadedKey = "downloadedKey"
    
    func downloadedEpisodes() -> [Episode] {
        guard let episodesData =  UserDefaults.standard.data(forKey: UserDefaults.downloadedKey) else { return  [] }
        
        do {
            let episodes = try JSONDecoder().decode([Episode].self, from: episodesData)
            return episodes
        }catch let error {
            print("error in decoding",error)
        }
        
        return []
        
    }
    
    func downloadEpisode(episode:Episode){
        do {
            var episodes = downloadedEpisodes()
            episodes.append(episode)
            let data = try JSONEncoder().encode(episodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.downloadedKey)
            
        }catch let error {
            print("error when encode episode:",error)
        }
        
        
    }
    
    func savedPodcasts() -> [Podcast] {
        guard let savedPodcastData = UserDefaults.standard.data(forKey: UserDefaults.favouriteKey) else { return [] }
        guard let savedPodcasts = NSKeyedUnarchiver.unarchiveObject(with: savedPodcastData) as? [Podcast] else {return []}
        return savedPodcasts
    }
}
