//
//  DownloadsController.swift
//  PodCastApp
//
//  Created by Omar Khaled on 28/09/2022.
//

import UIKit

class DownloadsController:UITableViewController {
    fileprivate let cellId = "cellId"
    var episodes = UserDefaults.standard.downloadedEpisodes()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupObservers()
    }
    
    fileprivate func setupObservers(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgress), name: .downloadEpisodePogress, object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgressCompleted), name: .downloadEpisodeCompleted, object: nil)
    }
    
    
    @objc fileprivate func handleDownloadProgressCompleted(notification:Notification){
        guard let episodeCompleteObject = notification.object as? APIService.EpisodeDownloadCompletedTuple else {
            return
        }
        
        guard let indexRow = self.episodes.firstIndex(where: {$0.title == episodeCompleteObject.title}) else { return }
        
        self.episodes[indexRow].fileUrl = episodeCompleteObject.fileUrl
    }
    
    @objc fileprivate func handleDownloadProgress(notification:Notification){
            
        guard let userInfo = notification.userInfo as? [String:Any] else {return}
        guard let progress = userInfo["progress"] as? Double else {return}
        guard let title = userInfo["title"] as? String else {return}
        
        guard let indexRow = self.episodes.firstIndex(where: {$0.title == title}) else { return }
        let cell =  tableView.cellForRow(at: IndexPath(row: indexRow, section: 0)) as? EpisodeCellTableViewCell
        cell?.progressLabel.isHidden = false
        cell?.progressLabel.text = "\(Int(progress * 100))%"
        
        if progress == 1 {
            cell?.progressLabel.isHidden = true
        }
        
    }
    
    
//    MARK: SETUP
    fileprivate func setupTableView(){
        let nib = UINib(nibName: "EpisodeCellTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        episodes = UserDefaults.standard.downloadedEpisodes()
        tableView.reloadData()
    }
    
//    MARK: uitableview
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = self.episodes[indexPath.row]
        
        if episode.fileUrl != nil {
            UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: episode,playlistEpisodes: self.episodes)
        }else{
            let alertController = UIAlertController(title: "File not found", message: "playing using stream audio?", preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: "Yes", style: .default,handler: { _ in
                
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            
            present(alertController, animated: true)
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCellTableViewCell
        cell.episode = self.episodes[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    
    
}

