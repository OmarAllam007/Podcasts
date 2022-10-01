//
//  PlayerDetails.swift
//  PodCastApp
//
//  Created by Omar Khaled on 14/09/2022.
//

import UIKit
import AVKit
import MediaPlayer

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
            self.setupElapsedTime(rate: 1)
        }else{
            player.play()
            playButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            animateImageView()
            self.setupElapsedTime(rate: 0)
        }
        
    }
    
    
    var episode:Episode! {
        didSet {
            episodeTitle.text = episode.title ?? ""
            episodeImageView.sd_setImage(with: URL(string: episode.imageUrl?.toHttps() ?? ""))
            authorLabel.text = episode.author
            
            playEpisode()
            setupAudioSession()
            
            minititleLabel.text = episode.title
            miniImageView.sd_setImage(with: URL(string: episode.imageUrl?.toHttps() ?? ""))
            
            setupNowPlayingInfoScreen()
            miniImageView.sd_setImage(with: URL(string: episode.imageUrl?.toHttps() ?? "")) { image, _, _, _ in
                guard let image = image else { return }
                
                let artWork = MPMediaItemArtwork(boundsSize: image.size) { _ in
                    return image
                }
                
                var nowPlaying:[String:Any] = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
                
                nowPlaying[MPMediaItemPropertyArtwork] = artWork
                
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlaying
                
            }
        }
    }
    
    fileprivate func setupNowPlayingInfoScreen(){
        var info = [String:Any]()
        info[MPMediaItemPropertyTitle] = episode.title
        info[MPMediaItemPropertyArtist] = episode.author
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    let player:AVPlayer = {
        let player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = false
        return player
    }()
    
    
    
    var panGesture:UIPanGestureRecognizer!
    
   
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupRemoteControl()
//        setupAudioSession()
        setupGestures()
        
        observePlayerTime()
        
        self.backgroundColor = .white
        
        observeTime()
        setupInterruption()
    }
    
    fileprivate func setupInterruption(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    @objc fileprivate func handleInterruption(notification:Notification){
        guard let userInfo = notification.userInfo else { return }
        guard let type = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else { return }
        
        
        if type == AVAudioSession.InterruptionType.began.rawValue {
            playButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        }else{
            
            guard let option = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            if option == AVAudioSession.InterruptionOptions.shouldResume.rawValue { //when call end as example
                player.play()
                playButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            }
            
        }
    }
    
    
    
    
    
    
    fileprivate func setupLockScreenDuration(){
        guard let duration = player.currentItem?.duration else { return }
        let durationInSec = CMTimeGetSeconds(duration)
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationInSec
    }
    
    
    fileprivate func observeTime() {
        let time = CMTimeMake(value: 1, timescale: 1)
        let times = [NSValue(time: time)]
        
        self.player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            self?.animateImageView()
            self?.setupLockScreenDuration()
        }
        
    }
   
    
    fileprivate func setupRemoteControl(){
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        let commandShared = MPRemoteCommandCenter.shared()
        
        commandShared.playCommand.isEnabled = true
        
        commandShared.playCommand.addTarget { _ in
            self.player.play()
            self.playButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self.setupElapsedTime(rate: 1)
            return .success
        }
        commandShared.pauseCommand.isEnabled = true
        
        commandShared.pauseCommand.addTarget { _ in
            self.player.pause()
            self.playButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.setupElapsedTime(rate: 0)
            
            return .success
        }
        
        commandShared.togglePlayPauseCommand.isEnabled = true
        commandShared.togglePlayPauseCommand.addTarget { _ in
            self.handePlayAndPause()
            return .success
        }
        
        
        commandShared.nextTrackCommand.isEnabled = true
        commandShared.nextTrackCommand.addTarget(self, action: #selector(handleNextTrack))

        commandShared.previousTrackCommand.addTarget(self, action: #selector(handlePrevTrack))
    }
    
    var playlistEpisodes = [Episode]()
    
    @objc fileprivate func handlePrevTrack() -> MPRemoteCommandHandlerStatus{
        if playlistEpisodes.count == 0 {
            return .commandFailed
        }
        
        let currentIndex = playlistEpisodes.firstIndex { episode in
            return self.episode.title == episode.title && self.episode.author == episode.author
        }
        
        guard let currentIndex else {return .commandFailed}
        
        let prevEpisode:Episode
        
        if currentIndex == 0 {
            prevEpisode = playlistEpisodes[playlistEpisodes.count - 1]
        }else{
            prevEpisode = playlistEpisodes[currentIndex - 1]
        }
        
        self.episode = prevEpisode
        return .success
    }
    
    @objc func handleNextTrack() -> MPRemoteCommandHandlerStatus{
        if playlistEpisodes.count == 0 {
            return .commandFailed
        }
        
        let currentIndex = playlistEpisodes.firstIndex { episode in
            return self.episode.title == episode.title && self.episode.author == episode.author
        }
        
        guard let currentIndex else {return .commandFailed}
        
        let nextEpisode:Episode
        
        if currentIndex == playlistEpisodes.count - 1 {
            nextEpisode = playlistEpisodes[0]
        }else{
            nextEpisode = playlistEpisodes[currentIndex + 1]
        }
        
        self.episode = nextEpisode
        return .success
    }
    
    
    fileprivate func setupElapsedTime(rate:Float){
        
        let elapsedTime = CMTimeGetSeconds(player.currentTime())
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] =  elapsedTime
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = rate
    }
    
    
    fileprivate func setupAudioSession(){
//        run sound in the background
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        }catch let error {
            print(error)
        }
        
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
//            self?.setupLockScreenTime()
            
            
        }
    }
//
//    fileprivate func setupLockScreenTime(){
//        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
//        guard let item = player.currentItem else {  return }
//        let durationInSec = CMTimeGetSeconds(item.duration)
//
//        let elapsedTime = CMTimeGetSeconds(player.currentTime())
//
//        nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
//        nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationInSec
//
//        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
//
//    }
    
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
        
        if episode.fileUrl != nil {
            self.playEpisodeUsingFileManager()
        }else{
            guard let episodeUrl = URL(string: episode.streamUrl.toHttps()) else { return }
            let playerItem = AVPlayerItem(url: episodeUrl)
            player.replaceCurrentItem(with: playerItem)
            player.play()
        }
        
        
    }
    
    fileprivate func playEpisodeUsingFileManager(){
        guard let fileUrl = URL(string: episode.fileUrl ?? "") else {  return }
        let fileName = fileUrl.lastPathComponent
        guard var fileLocation = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
         
        fileLocation.appendPathComponent(fileName)
        let playerItem = AVPlayerItem(url: fileLocation)
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
        
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seekTimeInSeconds
        
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

