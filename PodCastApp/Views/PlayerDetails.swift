//
//  PlayerDetails.swift
//  PodCastApp
//
//  Created by Omar Khaled on 14/09/2022.
//

import UIKit
import AVKit

class PlayerDetails:UIView {
    
    @IBOutlet weak var authorLabel: UILabel!

    @IBOutlet weak var playButton: UIButton! {
        didSet {
            playButton.addTarget(self, action: #selector(handePlayAndPause), for: .touchUpInside)
            playButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        }
    }
    
    @objc fileprivate func handePlayAndPause(){
        
        if player.timeControlStatus == .playing {
            player.pause()
            playButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            reverseAnimateImageView()
        }else{
            player.play()
            playButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            animateImageView()
        }
        
    }
    
    
    var episode:Episode! {
        didSet {
            episodeTitle.text = episode.title ?? ""
            episodeImageView.sd_setImage(with: URL(string: episode.imageUrl?.toHttps() ?? ""))
            authorLabel.text = episode.author
            
            playEpisode()
            
            minititleLabel.text = episode.title
            miniImageView.sd_setImage(with: URL(string: episode.imageUrl?.toHttps() ?? ""))
        }
    }
    
    let player:AVPlayer = {
        let player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = false
        return player
    }()
    
    
    
    var panGesture:UIPanGestureRecognizer!
    
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .white
        
        observePlayerTime()
        
        let time = CMTimeMake(value: 1, timescale: 1)
        let times = [NSValue(time: time)]
        
        self.player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            self?.animateImageView()
        }
        
        setupGestures()
        
    }
   
    
    fileprivate func setupGestures() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximize)))
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        miniStackView.addGestureRecognizer(panGesture)
        
        maxStackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissalPan)))
    }
    
    @objc func handleDismissalPan(gesture:UIPanGestureRecognizer){
        if gesture.state == .changed {
            let translation = gesture.translation(in: self.superview)
            maxStackView.transform = CGAffineTransform(translationX: 0, y: translation.y)
        } else if gesture.state == .ended {
            let translation = gesture.translation(in: self.superview)
            
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut) {
                
                if translation.y > 50 {
                    let mainTabController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
                    mainTabController?.minimizePlayerDetails()
                }else{
                    self.maxStackView.transform = .identity
                }
            }

        }
    }
    
    
    fileprivate func observePlayerTime() {
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            
            self?.currentTimeLabel.text = time.toDisplayStringFormat()
            self?.durationLabel.text = self?.player.currentItem?.duration.toDisplayStringFormat()
            self?.updateTimeSlider()
        }
    }
    
    deinit {
        print("no retain cycles 🔥")
    }
    
    static func initFromNib() -> PlayerDetails {
        return Bundle.main.loadNibNamed("PlayerDetails", owner: self,options: nil)?.first as! PlayerDetails
    }
    
    fileprivate func updateTimeSlider(){
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        let percentage = currentTimeSeconds / durationSeconds
        self.timeSlider.value = Float(percentage)
    }
    
    fileprivate func playEpisode(){
        guard let episodeUrl = URL(string: episode.streamUrl.toHttps()) else { return }
        let playerItem = AVPlayerItem(url: episodeUrl)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    
//    MARK: IB Props
    
    
    
    @IBOutlet weak var miniImageView: UIImageView!
    
    @IBOutlet weak var miniPlayPauseButton: UIButton! {
        didSet{
            miniPlayPauseButton.addTarget(self, action: #selector(handePlayAndPause), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var minititleLabel: UILabel!
    @IBOutlet weak var miniForwardButton: UIButton!
    
    @IBAction func miniForwardButton(_ sender: Any) {
        
    }
    
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    
    
    @IBOutlet weak var maxStackView: UIStackView!
    @IBOutlet weak var miniStackView: UIView!
    
    
    
    
    @IBAction func handleDismiss(_ sender:Any){
        let mainTabbarController = UIApplication.shared.keyWindow?.rootViewController as?MainTabBarController
        mainTabbarController?.minimizePlayerDetails()
    }
    
    
    
    
    
    fileprivate func animateImageView(){
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.episodeImageView.transform = .identity
        } completion: { _ in
            
        }
    }
    
    
    
    fileprivate let scaleTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    
    fileprivate func reverseAnimateImageView(){
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut) {

            self.episodeImageView.transform = self.scaleTransform
        } completion: { _ in
            
        }
    }
    
    @IBOutlet weak var episodeImageView:UIImageView! {
        didSet {
            episodeImageView.layer.cornerRadius = 5
            episodeImageView.clipsToBounds = true
        
            episodeImageView.transform = scaleTransform
        }
    }
    
    @IBOutlet weak var episodeTitle:UILabel! {
        didSet {
            episodeTitle.numberOfLines = 2
        }
    }
    
    
  
    @IBAction func handleTimeSliderChange(_ sender: Any) {
        let percentage = timeSlider.value
        guard let duration = player.currentItem?.duration else {  return }
        
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1)
        player.seek(to: seekTime)
        
    }
    
    @IBAction func handleRewind(_ sender: Any) {
        seekToTime(diff: -15)
    }
    
    @IBAction func handleForward(_ sender: Any) {
       seekToTime(diff: 15)
    }
    
    fileprivate func seekToTime(diff:Int64){
        let fifteenSeconds = CMTimeMake(value: diff, timescale: 1)
        let seekTime = CMTimeAdd(player.currentTime(), fifteenSeconds)
        player.seek(to: seekTime)
    }
    
    @IBAction func handleVolumeChange(_ sender: UISlider) {
        player.volume = sender.value
    }
    
}

