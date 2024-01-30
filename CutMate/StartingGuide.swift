//
//  StartingGuide.swift
//  CutMate
//
//  Created by Niklas on 13.12.23.
//

import Foundation
import AppKit
import Cocoa
import SwiftUI
import AVKit

struct StartSlide: View {
    @Environment(\.dismiss) var dismiss
    
    let player = AVPlayer(url: Bundle.main.url(forResource: "Videos/Copy", withExtension: "mov")!)
    
    init() {
        var first_start = UserDefaults.standard.string(forKey: "first-start")
        
        if (first_start == "no") {
            dismiss()
        } else {
            UserDefaults.standard.set("no", forKey: "first-start")
        }
    }
    
    var body: some View {
        VStack {
            VideoPlayer(player: player)
                .frame(height: 500)
                .onAppear {
                    player.play()
                    NotificationCenter.default.addObserver(forName: AVPlayerItem.didPlayToEndTimeNotification, object: nil, queue: nil) { notification in
                        player.seek(to: .zero)
                        player.play()
                    }
                }.onDisappear {
                    player.pause()
                }
            Button("Skip") {
                togglePanelVisibility()
                dismiss()
            }
            Button("Next") {
            }
        }
    }
}

struct Slide1: View {
    var body: some View {
        Text("")
    }
}

struct Slide2: View {
    var body: some View {
        Text("")
    }
}

struct Slide3: View {
    var body: some View {
        Text("")
    }
}
