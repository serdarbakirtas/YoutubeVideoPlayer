//
//  VideoPlayer.swift
//  FlavorOfCities
//
//  Created by Hasan on 21.12.20.
//  Copyright © 2020 FlavorOfCities. All rights reserved.
//

import AVKit
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
    private(set) var isFullScreen: Bool
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var videoPlayerState: VideoPlayerState
    
    @State var isSound: Bool = true
    @State var showingDetail: Bool = false
    @State var isPlaying: Bool = false
    @State var time: Float = 0
    @State var duration: Double = 0.0
    
    var body: some View {
        ZStack {
            WebViewContainer(webview: webview, videoID: videoID, videoPlayer: self,
                             currentTime: videoPlayerState.currentTime)
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

                if isFullScreen {
                    Button(action: {
                        pause()
                        videoPlayerState.currentTime = time
                        showingDetail = isFullScreen
                    }, label: {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .foregroundColor(.orange)
                    })
                } else {
                    Button(action: {
                        videoPlayerState.currentTime = time
                        presentationMode.wrappedValue.dismiss()
                        AppUtility.lockOrientation(.all)
                    }, label: {
                        Image(systemName: "arrow.down.right.and.arrow.up.left")
                            .foregroundColor(.orange)
                    })
                }
            }
            .padding()
            .offset(x: 0, y: 130)
        }
        .fullScreenCover(isPresented: $showingDetail, onDismiss: {
            seek(toSeconds: videoPlayerState.currentTime, allowSeekAhead: true)
        }, content: {
            VideoPlayerContainer(videoID: videoID, isFullScreen: false)
                .edgesIgnoringSafeArea(.all)
        })
    }
    
    init(videoID: String, isFullScreen: Bool) {
        self.videoID = videoID
        self.webview = WKWebView(frame: .zero, configuration: configuration)
        self.isFullScreen = isFullScreen
    }
    
    private func sliderEditingChanged(editingStarted: Bool) {
        editingStarted ? pause() : seek(toSeconds: time, allowSeekAhead: true)
    }
    
    func play() {
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

    func seek(toSeconds seekToSeconds: Float, allowSeekAhead: Bool) {
        let allowSeekAheadValue = String(allowSeekAhead)
        let command = "player.seekTo(\(seekToSeconds), \(allowSeekAheadValue));"
        stringFromEvaluatingJavaScript(command) { _, _ in
            play()
        }
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
