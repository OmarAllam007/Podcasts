//
//  PodcastsSearchController.swift
//  PodCastApp
//
//  Created by Omar Khaled on 05/09/2022.
//

import UIKit
import Alamofire



class PodcastsSearchController : UITableViewController {
    var timer:Timer?
    let cellID = "podcastCell"
    
    var podcasts:[Podcast] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setupTableView()
        
        searchBar(searchController.searchBar, textDidChange: "Voong")
        
    }
    
    // MARK: Setup - view-did-load
    fileprivate func setupTableView(){
        tableView.tableFooterView = UIView()
        
        
        let nibClass = UINib(nibName: "PodcastCell", bundle: nil)
        tableView.register(nibClass, forCellReuseIdentifier: cellID)
    }
    
    fileprivate func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    
    
    //    MARK: - tableview funcs
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let controller = EpisodesController()
        controller.podcast = podcasts[indexPath.row]
        navigationController?.pushViewController(controller, animated: true)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID,for: indexPath) as! PodcastCell
        cell.podcast = podcasts[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "No results, please enter a search query!"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18 ,weight:.semibold)
        label.textColor = .purple
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.podcasts.isEmpty ? 200 : 0
    }
    
}

// MARK: Extension

extension PodcastsSearchController:UISearchBarDelegate {
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText:  String) {
        
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
            APIService.shared
                .loadPodcasts(searchText: searchText) { podcasts in
                    self.podcasts = podcasts
                    self.tableView.reloadData()
                }
        })
        
        
    }
}
