//
//  EpisodeCellTableViewCell.swift
//  PodCastApp
//
//  Created by Omar Khaled on 09/09/2022.
//

import UIKit

class EpisodeCellTableViewCell: UITableViewCell {
    
    var episode:Episode! {
        didSet {
            titleLabel.text = episode.title
            descriptionLabel.text = episode.description
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            episodeDateLabel.text =  dateFormatter.string(from: episode.pubDate ?? Date())
            
            let url = URL(string: episode.imageUrl?.toHttps() ?? "")
            episodeImageView.sd_setImage(with: url)
            
        }
    }
    
    
    @IBOutlet weak var episodeImageView: UIImageView!
    
    @IBOutlet weak var episodeDateLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.numberOfLines = 2
        }
    }
    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.numberOfLines = 2
        }
    }
    
    
}
