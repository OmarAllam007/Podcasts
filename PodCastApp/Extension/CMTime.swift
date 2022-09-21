//
//  CMTime.swift
//  PodCastApp
//
//  Created by Omar Khaled on 19/09/2022.
//

import AVKit

extension CMTime {
    
    func toDisplayStringFormat() -> String {
        
        if CMTimeGetSeconds(self).isNaN {
            return "--:--"
        }
        let totalSeconds = Int(CMTimeGetSeconds(self))
        let seconds = totalSeconds % 60
        let minutes = totalSeconds / 60
        
        let timeFormat = String(format: "%02d:%02d", minutes,seconds)
        
        return timeFormat
        
    }
    
}

