//
//  ContentView.swift
//  CutMate
//
//  Created by Niklas on 27.11.23.
//

import SwiftUI
import HotKey

struct Copy: Identifiable, Equatable {
    let content: String
    let id = UUID()
}

class Copies: ObservableObject {
    @Published public var clipboard: [Copy] = []
}

func formatString(_ input: String) -> String {
    var formattedString = input.trimmingCharacters(in: .whitespacesAndNewlines)

    formattedString = formattedString.replacingOccurrences(of: "^\t+", with: " ", options: .regularExpression)

    if formattedString.count > 80 {
        let endIndex = formattedString.index(formattedString.startIndex, offsetBy: 80)
        formattedString = String(formattedString[..<endIndex]) + "..."
    }

    return formattedString
}

func formatStringSmall(_ input: String) -> String {
    var formattedString = input.trimmingCharacters(in: .whitespacesAndNewlines)

    formattedString = formattedString.replacingOccurrences(of: "^\t+", with: " ", options: .regularExpression)

    if formattedString.count > 45 {
        let endIndex = formattedString.index(formattedString.startIndex, offsetBy: 80)
        formattedString = String(formattedString[..<endIndex]) + "..."
    }

    return formattedString
}

struct CopyPanel: View {
    @ObservedObject var copies = Copies()
    var mode: String
    
    init() {
        if let i = UserDefaults.standard.string(forKey: "mode") {
            self.mode = i
        } else {
            self.mode = ""
        }
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        togglePanelVisibility()
                    }, label: {
                        ZStack {
                            Circle()
                                .fill(Color.secondary)
                                .frame(width: 15)
                            Image(systemName: "xmark")
                                .font(.system(size: 8, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        .contentShape(Circle())
                    })
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel(Text("Close"))
                    Spacer()
                        .frame(width: 15)
                }
                ScrollView {
                    ForEach(copies.clipboard) { copy in
                        HStack {
                            Button(action: {
                                let pasteboard = NSPasteboard.general
                                pasteboard.clearContents()
                                pasteboard.setString(copy.content, forType: .string)
                                if (mode == "paste") {
                                    pasteObject()
                                }
                            }) {
                                HStack {
                                    Text(formatString(copy.content))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                .padding(10)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.blue)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .id(copy.id)
                            Menu {
                                Button(action: {
                                    if let index = self.copies.clipboard.firstIndex(where: { $0.id == copy.id }) {
                                        self.copies.clipboard.remove(at: index)
                                    }
                                }) {
                                    Text("Entfernen")
                                    Image(systemName: "minus.circle")
                                        .font(.system(size: 24))
                                        .padding()
                                        .foregroundColor(.white)
                                }
                                
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .font(.system(size: 24))
                                    .padding()
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: 45)
                        }
                    }
                    .padding()
                    .onChange(of: copies.clipboard.count) {
                        if(copies.clipboard.count != 0) {
                            proxy.scrollTo(copies.clipboard.first!.id)
                        }
                    }
                }
                .frame(width: 400)
                HStack {
                    Text(getHotKeyStrings().0)
                        .font(Font.system(size: 14, weight: .bold))
                        .padding(2)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.primary, lineWidth: 1))
                    Text(getHotKeyStrings().1)
                        .font(Font.system(size: 14, weight: .bold))
                        .padding(2)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.primary, lineWidth: 1))
                    Text(" Hide/open panel")
                }
                HStack {
                    SettingsLink {
                        Text("Settings")
                    }
                    Button("Clear history") {
                        copies.clipboard.removeAll()
                    }
                    Button("Quit") {
                        NSApplication.shared.terminate(self)
                    }
                }
                Spacer(minLength: 10)
            }
        }
    }
}

struct ControlPanel: View {
    @Environment(\.dismiss) var dismiss
    @State public var mode = "Paste on click"
    let modes = ["Paste on click", "Copy on click"]
    @State public var hotkey_first = "ctrl"
    let hotkeys = ["control", "option", "command"]
    @State public var hotkey_second = "V"
    
    var body: some View {
        VStack {
            HStack {
                Picker("HotKey: ", selection: $hotkey_first) {
                    ForEach(hotkeys, id: \.self) { hotkey in
                        Text(hotkey)
                    }
                }
                .frame(width: 150)
                .onChange(of: mode) {
                    if (mode == modes[0]) {
                        UserDefaults.standard.set("paste", forKey: "mode")
                    } else {
                        UserDefaults.standard.set("copy", forKey: "mode")
                    }
                }
                .onAppear() {
                    if let i = UserDefaults.standard.string(forKey: "hotkey_first") {
                        self.hotkey_first = i
                    }
                }
                .onChange(of: hotkey_first) {
                    UserDefaults.standard.set(hotkey_first, forKey: "hotkey_first")
                }
                
                Picker("+ ", selection: $hotkey_second) {
                    ForEach(alphabet, id: \.self) { letter in
                        Text(String(letter))
                    }
                }
                .frame(width: 100)
                .onAppear() {
                    if let p = UserDefaults.standard.string(forKey: "hotkey_second") {
                        self.hotkey_second = p
                    }
                }
                .onChange(of: hotkey_second) {
                    UserDefaults.standard.set(hotkey_second, forKey: "hotkey_second")
                }
            }
            Picker("Mode: ", selection: $mode) {
                ForEach(modes, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 250)
            .onChange(of: mode) {
                if (mode == modes[0]) {
                    UserDefaults.standard.set("paste", forKey: "mode")
                } else {
                    UserDefaults.standard.set("copy", forKey: "mode")
                }
            }
            .onAppear() {
                if let i = UserDefaults.standard.string(forKey: "mode") {
                    if (i == "paste") {
                        self.mode = modes[0]
                    } else if (i == "copy") {
                        self.mode = modes[1]
                    }
                }
            }
            
            Spacer()
                .frame(height: 20)
            
            HStack {
                Button("Exit without saving") {
                    dismiss()
                }
                
                Button("Save & Exit") {
                    showNotification(message: "Restart the application for the settings to take effect!")
                    NSApplication.shared.terminate(self)
                }
            }
        }
    }
}
