//
//  NotificationPopUp.swift
//  CutMate
//
//  Created by Niklas on 12.12.23.
//

import Foundation
import AppKit
import HotKey
import SwiftUI

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

private func getColorFromName(color: String) -> Color {
    switch color {
    case "red":
        return .red
    case "orange":
        return .orange
    case "yellow":
        return .yellow
    case "blue":
        return .blue
    case "green":
        return .green
    case "purple":
        return .purple
    case "grey":
        return Color(red: 41/255, green: 42/255, blue: 41/255)
    case "black":
        return .black
    default:
        return .gray
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

func getBackground() -> (Color, Double) {
    let background_color = UserDefaults.standard.string(forKey: "backgroundcolor") ?? "grey"
    var background_opacity = UserDefaults.standard.double(forKey: "background_opacity")
    
    background_opacity = background_opacity / 10
    
    if background_opacity <= 0 {
        background_opacity = 0.1
    }
    
    return (getColorFromName(color: background_color), background_opacity)
}

func getButtonColor() -> (Color) {
    let button_color = UserDefaults.standard.string(forKey: "buttoncolor") ?? "blue"
    
    return getColorFromName(color: button_color)
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
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            let event1 = CGEvent(keyboardEventSource: nil, virtualKey: 0x09, keyDown: true);
            event1?.flags = CGEventFlags.maskCommand;
            event1?.post(tap: CGEventTapLocation.cghidEventTap);

            let event2 = CGEvent(keyboardEventSource: nil, virtualKey: 0x09, keyDown: false)
            event2?.post(tap: CGEventTapLocation.cghidEventTap)
        }
    }
}
