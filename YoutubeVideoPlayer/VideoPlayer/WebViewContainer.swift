//
//  WebViewContainer.swift
//  FlavorOfCities
//
//  Created by Hasan on 04.01.21.
//  Copyright © 2021 FlavorOfCities. All rights reserved.
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

enum CallBackType: String {
    case ready = "onReady"
    case stateChange = "onStateChange"
    case playbackQualityChange = "onPlaybackQualityChange"
    case error = "onError"
    case playTime = "onPlayTime"
    case failed = "onYouTubeIframeAPIFailedToLoad"
}

enum PlayerStateType: String {
    case unstartedCode = "-1"
    case endedCode = "0"
    case playingCode = "1"
    case pausedCode = "2"
    case bufferingCode = "3"
    case cuedCode = "5"
    case unknownCode = "unknown"
}

struct WebViewContainer: UIViewRepresentable {
    private(set) var webview: WKWebView
    private(set) var videoID: String
    private(set) var videoPlayer: VideoPlayer
    private(set) var currentTime: Float
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, videoplayer: videoPlayer, currentTime: currentTime)
    }

    func makeUIView(context: UIViewRepresentableContext<WebViewContainer>) -> WKWebView {
        webview.uiDelegate = context.coordinator
        webview.navigationDelegate = context.coordinator

        let playerVars = [
            "controls": 0,
            "playsinline": 1,
            "autohide": 1,
            "showinfo": 0,
            "modestbranding": 0
        ]

        let playerCallbacks = [
            "onReady": "onReady",
            "onStateChange": "onStateChange",
            "onPlaybackQualityChange": "onPlaybackQualityChange",
            "onError": "onPlayerError"
        ]

        let playerParams = [ "videoId": videoID, "playerVars": playerVars ] as NSMutableDictionary
        playerParams.setValue("100%", forKey: "height")
        playerParams.setValue("100%", forKey: "width")
        playerParams.setValue(playerCallbacks, forKey: "events")

        guard let path = Bundle.main.path(forResource: "Youtube-iframe-player", ofType: "html") else { return webview }
        var embedHTMLTemplate: String?
        do { embedHTMLTemplate = try String(contentsOfFile: path, encoding: .utf8) } catch {}

        var jsonData: Data?
        do { jsonData = try JSONSerialization.data(withJSONObject: playerParams, options: .prettyPrinted) } catch {}
        var playerVarsJsonString: String?
        if let jsonData = jsonData {
            playerVarsJsonString = String(data: jsonData, encoding: .utf8)
        }
        let embedHTML = String(format: embedHTMLTemplate ?? "", playerVarsJsonString ?? "")
        webview.loadHTMLString(embedHTML, baseURL: nil)
        
        return webview
    }

    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<WebViewContainer>) {}
}

class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate {

    var parent: WebViewContainer
    var videoPlayer: VideoPlayer
    var currentTime: Float

    init(_ parent: WebViewContainer, videoplayer: VideoPlayer, currentTime: Float) {
        self.parent = parent
        self.videoPlayer = videoplayer
        self.currentTime = currentTime
    }

    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: (WKNavigationActionPolicy) -> Void) {

        let request = navigationAction.request

        if request.url?.scheme == "ytplayer" {
            notifyDelegateOfYouTubeCallbackUrl(request.url)
            decisionHandler(.cancel)
            return
        } else if (request.url?.scheme == "http") || (request.url?.scheme == "https") {
            if handleHttpNavigation(to: request.url) {
                decisionHandler(.allow)
            } else {
                decisionHandler(.cancel)
            }
            return
        }

        decisionHandler(.allow)
    }

    private func notifyDelegateOfYouTubeCallbackUrl(_ url: URL?) {
        guard let action = url?.host else { return }
        let callBackType = CallBackType(rawValue: action)

        var data = PlayerStateType.unknownCode
        var time = ""
        if let query = url?.query {
            time = query.components(separatedBy: "=")[1]
            data = PlayerStateType(rawValue: time) ?? .unknownCode
        }
        
        switch callBackType {
        case .ready:
            getDuration { [weak self] duration, error in
                if error == nil {
                    self?.videoPlayer.duration = duration
                }
            }
            videoPlayer.seek(toSeconds: currentTime, allowSeekAhead: true)
        case .stateChange:
            notifyPlayerStateChange(playerStateType: data)
        case .playbackQualityChange:
            break
        case .error:
            break
        case .playTime:
            self.videoPlayer.time = (time as NSString).floatValue
        case .failed:
            break
        case .none:
            break
        }
    }
    
    private func notifyPlayerStateChange(playerStateType: PlayerStateType) {
        switch playerStateType {
        case .endedCode:
            break
        case .unstartedCode:
            break
        case .playingCode:
            videoPlayer.isPlaying = true
        case .pausedCode:
            videoPlayer.isPlaying = false
        case .bufferingCode:
            break
        case .cuedCode:
            break
        case .unknownCode:
            break
        }
    }

    private func handleHttpNavigation(to url: URL?) -> Bool {
        return true
    }
    
    private func getDuration(_ completionHandler: ((_ duration: TimeInterval, _ error: Error?) -> Void)? = nil) {
        videoPlayer.stringFromEvaluatingJavaScript("player.getDuration();", completionHandler: { response, error in
            if let completionHandler = completionHandler {
                if let error = error {
                    completionHandler(0, error)
                } else {
                    if response != nil {
                        completionHandler(response as? Double ?? 0.0, nil)
                    } else {
                        completionHandler(0, nil)
                    }
                }
            }
        })
    }
}
