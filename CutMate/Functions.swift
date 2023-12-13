//
//  NotificationPopUp.swift
//  CutMate
//
//  Created by Niklas on 12.12.23.
//

import Foundation
import AppKit

func showNotification(message: String, informativeText: String? = nil) {
    let alert = NSAlert()
    alert.messageText = message
    if let informativeText = informativeText {
        alert.informativeText = informativeText
    }
    alert.alertStyle = .informational
    alert.addButton(withTitle: "OK")
    alert.runModal()
}

func pasteObject() {
    togglePanelVisibility()
    
    let runningApps = NSWorkspace.shared.runningApplications
    
    let currentApp = NSRunningApplication.current
    let filteredApps = runningApps.filter { $0 != currentApp }
    
    if let lastApp = filteredApps.last {
        lastApp.activate()
        
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
            let event1 = CGEvent(keyboardEventSource: nil, virtualKey: 0x09, keyDown: true);
            event1?.flags = CGEventFlags.maskCommand;
            event1?.post(tap: CGEventTapLocation.cghidEventTap);

            let event2 = CGEvent(keyboardEventSource: nil, virtualKey: 0x09, keyDown: false)
            event2?.post(tap: CGEventTapLocation.cghidEventTap)
        }
    }
}
