//
//  VideoPlayer.swift
//  FlavorOfCities
//
//  Created by Hasan on 21.12.20.
//  Copyright © 2020 FlavorOfCities. All rights reserved.
//

import SwiftUI
import WebKit

private var configuration: WKWebViewConfiguration {
    let webConfiguration = WKWebViewConfiguration()
    webConfiguration.allowsInlineMediaPlayback = true
    webConfiguration.allowsAirPlayForMediaPlayback = true
    webConfiguration.mediaTypesRequiringUserActionForPlayback = []
    return webConfiguration
}

struct VideoPlayer: View {
    
    private(set) var webview: WKWebView
    private(set) var videoID: String
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var isSound: Bool = true
    @State var showingDetail: Bool = false
    @State var isPlaying: Bool = false
    @State var time: Float = 0
    @State var duration: Double = 0.0
    
    var body: some View {
        ZStack {
            WebViewContainer(webview: webview, videoID: videoID, videoPlayer: self)
            HStack {
                Button(action: {
                    isPlaying ? pause() : play()
                }, label: {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .foregroundColor(.orange)
                })

                Slider(value: $time, in: 0...Float(duration), onEditingChanged: sliderEditingChanged) {}
                    .accentColor(.orange)

                Button(action: {
                    isSound.toggle()
                    isSound ? unMute() : mute()
                }, label: {
                    Image(systemName: isSound ? "speaker.3.fill" : "speaker.fill")
                        .foregroundColor(.orange)
                })
            }
            .padding()
            .offset(x: 0, y: 125)
        }
    }
    
    init(videoID: String) {
        self.videoID = videoID
        self.webview = WKWebView(frame: .zero, configuration: configuration)
    }
    
    private func sliderEditingChanged(editingStarted: Bool) {
        editingStarted ? pause() : seek(toSeconds: time, allowSeekAhead: true)
    }
    
    private func play() {
        stringFromEvaluatingJavaScript("player.playVideo();")
    }

    private func pause() {
        stringFromEvaluatingJavaScript("player.pauseVideo();")
    }

    private func stop() {
        stringFromEvaluatingJavaScript("player.stopVideo();")
    }
    
    private func mute() {
        stringFromEvaluatingJavaScript("player.mute();")
    }
    
    private func unMute() {
        stringFromEvaluatingJavaScript("player.unMute();")
    }

    private func seek(toSeconds seekToSeconds: Float, allowSeekAhead: Bool) {
        let allowSeekAheadValue = String(allowSeekAhead)
        let command = "player.seekTo(\(seekToSeconds), \(allowSeekAheadValue));"
        stringFromEvaluatingJavaScript(command, completionHandler: nil)
    }
    
    func stringFromEvaluatingJavaScript(_ jsToExecute: String,
                                        completionHandler: ((_ response: Any?, _ error: Error?) -> Void)? = nil) {
        self.webview.evaluateJavaScript(jsToExecute, completionHandler: { response, error in
            if let completionHandler = completionHandler {
                completionHandler(response, error)
            }
        })
    }
}
