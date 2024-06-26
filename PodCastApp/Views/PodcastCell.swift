//
//  PodcastCell.swift
//  PodCastApp
//
//  Created by Omar Khaled on 07/09/2022.
//

import UIKit
import SDWebImage

class PodcastCell:UITableViewCell {
    @IBOutlet weak var podcastImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var episodeCountLabel: UILabel!
    
    
    var podcast:Podcast! {
        didSet {
            trackNameLabel.text = podcast.trackName
            artistNameLabel.text = podcast.artistName
            episodeCountLabel.text = "\(podcast.trackCount ?? 0) Episodes"
            
            guard let url = URL(string: podcast.artworkUrl600 ?? "") else {  return }
            podcastImageView.sd_setImage(with: url)

        }
    }
    
    
    
    
}
