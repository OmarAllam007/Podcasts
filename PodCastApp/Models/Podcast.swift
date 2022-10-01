//
//  Podcast.swift
//  PodCastApp
//
//  Created by Omar Khaled on 05/09/2022.
//

import Foundation

class Podcast :NSObject, Decodable,NSCoding {
    func encode(with coder: NSCoder) {
        print("convert podcast to data")
        coder.encode(trackName ?? "", forKey: "trackNameKey")
        coder.encode(artistName ?? "", forKey: "artistNameKey")
        coder.encode(artworkUrl600 ?? "", forKey: "artworkKey")
        coder.encode(feedUrl ?? "", forKey: "feedUrl")
    }
    enum CodingKeys: CodingKey {
        case trackName
        case artistName
        case artworkUrl600
        case trackCount
        case feedUrl
    }
    
//    required init(from decoder: Decoder) throws {
//        print("convert podcast to podcast decoder")
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.trackName = try container.decodeIfPresent(String.self, forKey: .trackName)
//        self.artistName = try container.decodeIfPresent(String.self, forKey: .artistName)
//        self.artworkUrl600 = try container.decodeIfPresent(String.self, forKey: .artworkUrl600)
//        self.trackCount = try container.decodeIfPresent(Int.self, forKey: .trackCount)
//        self.feedUrl = try container.decodeIfPresent(String.self, forKey: .feedUrl)
//    }
    required init?(coder: NSCoder) {
        print("convert data to podcast")
        self.trackName = coder.decodeObject(forKey: "trackNameKey") as? String
        self.artistName = coder.decodeObject(forKey: "artistNameKey") as? String
        self.artworkUrl600 = coder.decodeObject(forKey: "artworkKey") as? String
        self.feedUrl = coder.decodeObject(forKey: "feedUrl") as? String
    }
    
    var trackName:String?
    var artistName:String?
    var artworkUrl600:String?
    var trackCount:Int?
    var feedUrl:String?
    
}
