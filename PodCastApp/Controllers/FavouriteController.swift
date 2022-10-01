//
//  FavouriteController.swift
//  PodCastApp
//
//  Created by Omar Khaled on 26/09/2022.
//

import UIKit

class FavouritesController:UICollectionViewController,UICollectionViewDelegateFlowLayout {
    let cellId = "favCellId"
    var podcasts = UserDefaults.standard.savedPodcasts()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
    
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        podcasts = UserDefaults.standard.savedPodcasts()
        collectionView.reloadData()
        UIApplication.mainTabBarController()?.viewControllers?[1].tabBarItem.badgeValue = nil
    }
    
    fileprivate func setupCollectionView(){
//        collectionView.backgroundColor = .white
        
        collectionView.register(FavouritePodcastCell.self, forCellWithReuseIdentifier: cellId)
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        collectionView.addGestureRecognizer(gesture)
    }
    
    @objc fileprivate func handleLongPress(gesture: UILongPressGestureRecognizer){
        let location  = gesture.location(in: collectionView)
        guard let selectedIndexPath = collectionView.indexPathForItem(at: location) else {return}
        let alert = UIAlertController(title: "Remove Podcast", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive,handler: { _ in
            self.podcasts.remove(at: selectedIndexPath.item)
            
            self.collectionView.deleteItems(at: [selectedIndexPath])
            
            self.removeFromUserDefault()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    fileprivate func removeFromUserDefault(){
        let data =  NSKeyedArchiver.archivedData(withRootObject: podcasts)
        UserDefaults.standard.set(data, forKey: UserDefaults.favouriteKey)
    }
//    MARK:  UI Collection View funcs
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let episodesController = EpisodesController()
        episodesController.podcast = self.podcasts[indexPath.item]
        navigationController?.pushViewController(episodesController, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3 * 16) / 2
        return .init(width: width, height: width + 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FavouritePodcastCell
        cell.podcast = self.podcasts[indexPath.item]
        return cell
    }
}

