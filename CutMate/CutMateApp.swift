//
//  CutMateApp.swift
//  CutMate
//
//  Created by Niklas on 27.11.23.
//

import SwiftUI
import Cocoa
import HotKey
import Sparkle

@main
struct CutMateApp: App {
    var copypanel = CopyPanel()
    var controlpanel = ControlPanel()
    var hotkey: HotKey
    var floating_copy_panel: FloatingPanel!
    public var settings = true
    
    private let updaterController: SPUStandardUpdaterController

    init() {
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
        
        let clipboard = Clipboard(copies:copypanel.copies)
        clipboard.startThread()
        
        var (hotkey_first, hotkey_second) = getHotKey()
        
        hotkey = HotKey(key: hotkey_second, modifiers: [hotkey_first], keyUpHandler: {
            togglePanelVisibility()
        })
        
        _ = copypanel.ignoresSafeArea(edges: .top)
        
        floating_copy_panel = FloatingPanel(contentRect: NSRect(x: 0, y: 0, width: 400, height: 500), backing: .buffered, defer: false)

        floating_copy_panel.title = "CutMate"
        floating_copy_panel.contentView = NSHostingView(rootView: copypanel)

        floating_copy_panel.center()

        floating_copy_panel.orderFront(nil)
        floating_copy_panel.makeKey()
        NSApp.setActivationPolicy(.accessory)
        
        togglePanelVisibility(panel_:floating_copy_panel)
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.modifierFlags.contains(NSEvent.ModifierFlags.control) {
                if keyCodeToNumber(event.keyCode) != nil {
                    var number = keyCodeToNumber(event.keyCode)!
                    var copy: Copy? = nil
                    
                    if number > 0 && number <= ext_clipboard.count {
                        copy = ext_clipboard[number-1]
                    } else {
                        return event
                    }
                
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(copy!.content, forType: .string)
                    pasteObject()
                }
            }
            return event
        }
    }
    
    var body: some Scene {
        Settings {
            if (settings) {
                controlpanel
                    .frame(width: 300, height: 500)
            } else {
                EmptyView()
            }
        }
        
        MenuBarExtra("CutMate", systemImage: "scissors") {
            Button("Open/Close Panel") {
                togglePanelVisibility()
            }
            Divider()
            if #available(macOS 14.0, *) {
                SettingsLink {
                    Text("Settings")
                }
            }
            else {
                Button(action: {
                    if #available(macOS 13.0, *) {
                        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                    }
                    else {
                        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                    }
                }, label: {
                    Text("Settings")
                })
            }
            Button("Clear history") {
                copypanel.copies.clipboard.removeAll()
                ext_clipboard = copypanel.copies.clipboard
            }
            Divider()
            CheckForUpdatesView(updater: updaterController.updater)
            Divider()
            Button("Quit") {
                NSApplication.shared.terminate(self)
            }
        }
        .commands {
            CommandGroup(after: .appInfo) {
                CheckForUpdatesView(updater: updaterController.updater)
            }
        }
    }
}

var isPanelVisible = true
var panel: FloatingPanel? = nil

func togglePanelVisibility(panel_: FloatingPanel? = nil) {
    if (panel_ != nil) {
        panel = panel_
        return
    }
    
    if isPanelVisible {
        if (panel!.isVisible == true) {
            panel?.setIsVisible(false)
        }
    } else {
        if (panel!.isVisible == false) {
            panel?.setIsVisible(true)
        }
    }
    
    isPanelVisible.toggle()
}

var ext_clipboard: [Copy] = []
