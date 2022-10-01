//
//  FavouritePodcastCell.swift
//  PodCastApp
//
//  Created by Omar Khaled on 26/09/2022.
//

import UIKit

class FavouritePodcastCell:UICollectionViewCell {
    let imageView = UIImageView(image: #imageLiteral(resourceName: "appicon"))
    let nameLabel = UILabel()
    let artistNameLabel = UILabel()
    
    var podcast:Podcast! {
        didSet{
            
            nameLabel.text = podcast.trackName
            artistNameLabel.text = podcast.artistName
            
            let url = URL(string: podcast.artworkUrl600 ?? "")
            imageView.sd_setImage(with: url)
        }
    }
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        styleUI()
        setupAnchors()
        
        
        
    }
    
    
    fileprivate func styleUI() {
        nameLabel.text = "Name"
        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        
        artistNameLabel.text = "artistNameLabel"
        artistNameLabel.font = .systemFont(ofSize: 14)
        artistNameLabel.textColor = .lightGray
    }
    
    
    fileprivate func setupAnchors() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        
        let vStackview = UIStackView(arrangedSubviews: [imageView,nameLabel,artistNameLabel])
        
        vStackview.axis = .vertical
        vStackview.spacing = 5
        self.addSubview(vStackview)
        
        
        
        vStackview.translatesAutoresizingMaskIntoConstraints = false
        
        vStackview.topAnchor.constraint(equalTo: topAnchor).isActive = true
        vStackview.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        vStackview.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        vStackview.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
