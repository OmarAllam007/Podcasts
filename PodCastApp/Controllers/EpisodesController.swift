//
//  EpisodesController.swift
//  PodCastApp
//
//  Created by Omar Khaled on 09/09/2022.
//

import UIKit
import FeedKit

class EpisodesController:UITableViewController {
    
    fileprivate let cellID = "cellId"
    
    var episodes:[Episode] = []
    
    var podcast:Podcast?{
        didSet{
            navigationItem.title = podcast?.trackName ?? "N/A"
            fetchEpisodes()
        }
    }
    
    
    fileprivate func fetchEpisodes(){
        episodes = []
        guard let feedUrl = podcast?.feedUrl else { return }
        
        APIService.shared.fetchEpisodes(feedUrl: feedUrl) { episodes in
            self.episodes = episodes
            
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    
    //    MARK: setup
    fileprivate func setupTableView() {
        let nib = UINib(nibName: "EpisodeCellTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellID)
        
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()
    }
    
    
    //    MARK: uitableview funcs
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID,for: indexPath) as! EpisodeCellTableViewCell
        
        cell.episode  =   episodes[indexPath.row]
        
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainTabbarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        mainTabbarController?.maximizePlayerDetails(episode: episodes[indexPath.row])
        
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return episodes.isEmpty ? 200 : 0
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        activityIndicator.color = .darkGray
        activityIndicator.startAnimating()
        return activityIndicator
    }
}

