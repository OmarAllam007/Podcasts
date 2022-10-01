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
    
    fileprivate func setupNavigationBarButtons(){
        let savedPodcasts = UserDefaults.standard.savedPodcasts()
        
        let isFavourite = savedPodcasts.firstIndex(where: {$0.trackName == self.podcast?.trackName &&
            $0.artistName == self.podcast?.artistName}) != nil
        
        if isFavourite {
            
            navigationItem.rightBarButtonItems = [
                .init(image: #imageLiteral(resourceName: "heart"), style: .plain, target: nil, action: nil)
                    
            ]
        }else{
            navigationItem.rightBarButtonItems = [
                    .init(title: "Favourite", style: .plain, target: self, action: #selector(handleSaveFavourite)),
            ]
        }
        
        
    }
    
    @objc fileprivate func handleFetchSavedFavourite(){
        guard let data = UserDefaults.standard.data(forKey: UserDefaults.favouriteKey) else { return }
        let podcasts = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Podcast]
        
        podcasts?.forEach({ p in
            print(p.trackName ?? "")
        })
        
    }
    
    
    
    
    @objc fileprivate func handleSaveFavourite(){
        guard let podcast = self.podcast else { return }
        
        var listOfSavedPodcasts = UserDefaults.standard.savedPodcasts()
        listOfSavedPodcasts.append(podcast)
        
        let data =  NSKeyedArchiver.archivedData(withRootObject: listOfSavedPodcasts)
        
        UserDefaults.standard.set(data, forKey: UserDefaults.favouriteKey)
        
        
        showBadgeAnimation()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "heart"), style: .plain, target: nil, action: nil)
        
        
    }
    
    fileprivate func showBadgeAnimation(){
        UIApplication.mainTabBarController()?.viewControllers?[1].tabBarItem.badgeValue = "New"
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
        setupNavigationBarButtons()
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
        
        cell.episode =  episodes[indexPath.row]
        
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainTabbarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        mainTabbarController?.maximizePlayerDetails(episode: episodes[indexPath.row],playlistEpisodes:self.episodes)
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
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let contextItem = UIContextualAction(style: .normal, title: "Download") {  (contextualAction, view, boolValue) in
            
            let episode = self.episodes[indexPath.row]
            UserDefaults.standard.downloadEpisode(episode: episode)
            
            APIService.shared.downloadEpisode(episode: episode)
            boolValue(true)
        }
        
        let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])
        contextItem.backgroundColor = .darkGray
        

        swipeActions.performsFirstActionWithFullSwipe = false
        
        return swipeActions
    }
}

