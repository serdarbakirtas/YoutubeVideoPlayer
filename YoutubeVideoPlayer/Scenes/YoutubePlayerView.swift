//
//  YoutubePlayerView.swift
//  YoutubeVideoPlayer
//
//  Created by Hasan on 08.01.21.
//

import Combine
import SwiftUI

struct YoutubePlayerView: View {
    @ObservedObject var viewModel: YoutubePlayerViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack {
                viewModel.player.frame(height: 300)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#if DEBUG

struct YoutubePlayerView_Previews: PreviewProvider {
    static var previews: some View {
        YoutubePlayerView(viewModel: .init(videoId: "HTdd8QxifbY"))
    }
}
#endif
