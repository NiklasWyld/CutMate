//
//  NotificationPopUp.swift
//  CutMate
//
//  Created by Niklas on 12.12.23.
//

import Foundation
import AppKit
import HotKey

let alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

private func getHotKeyModifier(_ modifierString: String) -> NSEvent.ModifierFlags {
    switch modifierString.lowercased() {
    case "control":
        return .control
    case "command":
        return .command
    case "option":
        return .option
    default:
        return .control
    }
}

private func getHotKeyModifierString(_ modifierString: String) -> String {
    switch modifierString.lowercased() {
    case "control":
        return "⌃"
    case "command":
        return "⌘"
    case "option":
        return "⌥"
    default:
        return "⌃"
    }
}

func getHotKey() -> (NSEvent.ModifierFlags, Key) {
    let hotkey_first = getHotKeyModifier(UserDefaults.standard.string(forKey: "hotkey_first") ?? "control")
    let hotkey_second = Key(string: UserDefaults.standard.string(forKey: "hotkey_second") ?? "V") ?? .v
    
    return (hotkey_first, hotkey_second)
}

func getHotKeyStrings() -> (String, String) {
    let hotkey_first = getHotKeyModifierString(UserDefaults.standard.string(forKey: "hotkey_first") ?? "control")
    let hotkey_second = UserDefaults.standard.string(forKey: "hotkey_second") ?? "V"
    
    return (hotkey_first, hotkey_second)
}

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
