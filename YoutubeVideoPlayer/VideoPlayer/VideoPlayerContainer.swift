//
//  VideoPlayerContainer.swift
//  YoutubeVideoPlayer
//
//  Created by Hasan on 14.01.21.
//

import SwiftUI

struct VideoPlayerContainer: View {
        
    private(set) var videoID: String
    private(set) var isFullScreen: Bool = false
    
    var body: some View {
        VideoPlayer(videoID: videoID, isFullScreen: isFullScreen)
    }
    
    init(videoID: String, isFullScreen: Bool) {
        self.videoID = videoID
        self.isFullScreen = isFullScreen
        self.isFullScreen ? AppUtility.lockOrientation(.landscapeLeft) : AppUtility.lockOrientation(.all)
    }
}

#if DEBUG
struct VideoPlayerContainer_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayer(videoID: "514A7yzznJE", isFullScreen: true)
    }
}
#endif
