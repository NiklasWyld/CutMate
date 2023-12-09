//
//  CutMateApp.swift
//  CutMate
//
//  Created by Niklas on 27.11.23.
//

import SwiftUI
import Cocoa

@main
struct CutMateApp: App {
    var copypanel = CopyPanel()
    
    var body: some Scene {
        WindowGroup {
            copypanel
                .frame(width: 400, height: 500)
        }
    }
    
    
    init() {
        let clipboard = Clipboard(copies:copypanel.copies)
        clipboard.startThread()
    }
}
