//
//  MainTabBarController.swift
//  PodCastApp
//
//  Created by Omar Khaled on 05/09/2022.
//

import UIKit

class MainTabBarController:UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = .purple
        
        UINavigationBar.appearance().prefersLargeTitles = true
        
        
        
        tabBar.backgroundColor = .lightGray.withAlphaComponent(0.1)
        
        setupViewControllers()
        setupPlayerDetails()
        
//        perform(#selector(minimizePlayerDetails))
        
    }
    
    var maximizedTopAnchorContrained:NSLayoutConstraint!
    var minimizedTopAnchorContrained:NSLayoutConstraint!
    var bottomAnchorConstraint:NSLayoutConstraint!
    
    
    @objc func minimizePlayerDetails(){
        maximizedTopAnchorContrained.isActive = false
        bottomAnchorConstraint.constant = view.frame.height
        minimizedTopAnchorContrained.isActive = true
        
        
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
            self.tabBar.isHidden = false
            self.playerDetails.maxStackView.alpha = 0
            self.playerDetails.miniStackView.alpha = 1
        }

    }
    
    func maximizePlayerDetails(episode:Episode?){
        minimizedTopAnchorContrained.isActive = false
        maximizedTopAnchorContrained.isActive = true
        maximizedTopAnchorContrained.constant = 0
        
        
        bottomAnchorConstraint.constant = 0
        
        
        
        if episode != nil {
            playerDetails.episode = episode
        }
        
         
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
            self.tabBar.isHidden = true
            self.playerDetails.maxStackView.alpha = 1
            self.playerDetails.miniStackView.alpha = 0
        }
    }
    
    let playerDetails = PlayerDetails.initFromNib()
    
    fileprivate func setupPlayerDetails(){
        
        view.insertSubview(playerDetails, belowSubview: tabBar)
        
        playerDetails.translatesAutoresizingMaskIntoConstraints = false
        
        maximizedTopAnchorContrained = playerDetails.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        
        maximizedTopAnchorContrained.isActive = true
        

        bottomAnchorConstraint = playerDetails.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: view.frame.height)
        bottomAnchorConstraint.isActive = true
        
        minimizedTopAnchorContrained = playerDetails.topAnchor.constraint(equalTo: tabBar.topAnchor , constant: -64)
        
        playerDetails.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        
        playerDetails.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        
    }
    
    //MARK: - Setup Functions
    
    fileprivate func setupViewControllers() {
        let favouriteController = generateNavigationController(with: ViewController(), title: "Favourites", image: #imageLiteral(resourceName: "favorites"))
        let searchController = generateNavigationController(with: PodcastsSearchController(), title: "Search", image: #imageLiteral(resourceName: "search"))
        let downloadNavController = generateNavigationController(with: ViewController(), title: "Downloads", image: #imageLiteral(resourceName: "downloads"))
        
        
        viewControllers = [
            searchController,
            favouriteController,
            downloadNavController
        ]
    }
    
    
    //MARK: - helper functions
    
    fileprivate func generateNavigationController(with rootViewController:UIViewController, title:String, image:UIImage)-> UIViewController {
     
        let navViewController = UINavigationController(rootViewController: rootViewController)
        rootViewController.navigationItem.title = title
        navViewController.tabBarItem.title = title
        navViewController.tabBarItem.image = image
        
        return navViewController
        
    }
    
}
