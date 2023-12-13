//
//  CutMateApp.swift
//  CutMate
//
//  Created by Niklas on 27.11.23.
//

import SwiftUI
import Cocoa
import HotKey

@main
struct CutMateApp: App {
    var copypanel = CopyPanel()
    var controlpanel = ControlPanel()
    var hotkey: HotKey
    var floating_copy_panel: FloatingPanel!
    public var settings = true
    
    init() {
        let clipboard = Clipboard(copies:copypanel.copies)
        clipboard.startThread()
        
        hotkey = HotKey(key: .c, modifiers: [.control], keyDownHandler: {
            togglePanelVisibility()
        })
        
        _ = copypanel.ignoresSafeArea(edges: .top)

        floating_copy_panel = FloatingPanel(contentRect: NSRect(x: 0, y: 0, width: 400, height: 500), backing: .buffered, defer: false)

        floating_copy_panel.title = "CutMate"
        floating_copy_panel.contentView = NSHostingView(rootView: copypanel)

        floating_copy_panel.center()

        floating_copy_panel.orderFront(nil)
        floating_copy_panel.makeKey()
    }
    
    var body: some Scene {
        Settings {
            if (settings) {
                controlpanel
                    .frame(width: 300, height: 300)
            } else {
                EmptyView()
            }
        }
        
        MenuBarExtra("CutMate", systemImage: "scissors") {
            SettingsLink {
                Text("Settings")
            }
            Button("Clear history") {
                copypanel.copies.clipboard.removeAll()
            }
            Button("Quit") {
                NSApplication.shared.terminate(self)
            }
        }
    }
}

var isPanelVisible = true

func togglePanelVisibility() {
    if isPanelVisible {
        NSApplication.shared.hide(nil)
        NSApp.setActivationPolicy(.accessory)
    } else {
        NSApp.setActivationPolicy(.regular)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
    
    isPanelVisible.toggle()
}
