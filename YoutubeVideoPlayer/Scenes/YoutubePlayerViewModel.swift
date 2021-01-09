//
//  YoutubePlayerViewModel.swift
//  YoutubeVideoPlayer
//
//  Created by Hasan on 08.01.21.
//

import SwiftUI

final class YoutubePlayerViewModel: ObservableObject {
    
    @Published private(set) var videoId: String
    
    let player: VideoPlayer
    
    init(videoId: String) {
        self.videoId = videoId
        player = VideoPlayer(videoID: videoId)
    }
}
