//
//  APIService.swift
//  PodCastApp
//
//  Created by Omar Khaled on 06/09/2022.
//

import Foundation
import Alamofire
import FeedKit

class APIService {
    
    static let shared = APIService()
    
    func loadPodcasts(searchText:String,completion: @escaping ([Podcast])->()){
        
        let url = "https://itunes.apple.com/search"


        let params = ["term":searchText,"media":"podcast"]

        AF.request(url, method: .get, parameters: params, encoding: URLEncoding.queryString, headers: nil).responseData { response in
            if let error = response.error {
                print(error)
                return
            }

            guard let data = response.data else { return }

            do {
                let results = try JSONDecoder().decode(SearchResults.self, from: data)
                completion(results.results)
            }catch let decodeError {
                print(decodeError)
            }
        }
        
        
    }
    
    
    func fetchEpisodes(feedUrl:String,completion: @escaping ([Episode])->()){
        let securedFeedUrl = feedUrl.contains("https") ? feedUrl : feedUrl.replacingOccurrences(of: "http", with: "https")
        
        guard let url = URL(string: securedFeedUrl) else { return }
        
        DispatchQueue.global(qos: .background).async {
            let parser = FeedParser(URL: url)
            
            parser.parseAsync { (result) in
                
                switch result {
                case .success(let feed):
                    switch feed {
                    case let .rss(feed):
                        completion(feed.toEpisodes())
                        
                        break
                        
                    default:
                        print("default case")
                        
                    }
                    
                    
                case .failure(let error):
                    print(error)
                    
                }
                
            }
        }
        
        
        
    }
    
}
