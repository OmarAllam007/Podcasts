//
//  PlayerDetails + Gestures.swift
//  PodCastApp
//
//  Created by Omar Khaled on 21/09/2022.
//

import UIKit
import AVKit

extension PlayerDetails{
    @objc  func handlePan(gesture:UIPanGestureRecognizer){
        if gesture.state == .changed {
            handlePanChange(gesture)
            
        } else if gesture.state == .ended {
            handlePanGestureEnded(gesture)
            
        }
    }
    
    
    fileprivate func handlePanChange(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        self.miniStackView.alpha = 1 + (translation.y / 200)
        self.maxStackView.alpha = -translation.y / 200
    }
    
    
    fileprivate func handlePanGestureEnded(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        let velocity = gesture.velocity(in: self.superview)
        
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.transform = .identity
            
            if translation.y < -250 || velocity.y < -500 {
                let mainTabBarController = UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: nil)
            
//                gesture.isEnabled = false
            }else{
                self.miniStackView.alpha = 1
                self.maxStackView.alpha = 0
            
            }
            
        }
    }
    
    @objc  func handleTapMaximize(){
        UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: nil)

    }
    
}
